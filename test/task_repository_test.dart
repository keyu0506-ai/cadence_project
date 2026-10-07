import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadence_project/features/tasks/task.dart';
import 'package:cadence_project/features/tasks/task_repository.dart';

// Exercise the real repository's paths, serialization and batch behavior with
// a narrow Firestore adapter double. This does not emulate server security rules.
class RecordingFirestore extends Fake implements FirebaseFirestore {
  final writes = <String, Object?>{};
  final acknowledgement = Completer<void>();
  int commits = 0;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      RecordingCollection(path);
  @override
  WriteBatch batch() => RecordingBatch(this);
}

// Test-only double for SDK references; production code uses the SDK instances.
// ignore: subtype_of_sealed_class
class RecordingCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  RecordingCollection(this.location);
  final String location;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      RecordingDocument('$location/$path');
}

// ignore: subtype_of_sealed_class
class RecordingDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  RecordingDocument(this.path);
  @override
  final String path;
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      RecordingCollection('$path/$collectionPath');
}

class RecordingBatch extends Fake implements WriteBatch {
  RecordingBatch(this.firestore);
  final RecordingFirestore firestore;
  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    firestore.writes[document.path] = data;
  }

  @override
  Future<void> commit() {
    firestore.commits++;
    return firestore.acknowledgement.future;
  }
}

void main() {
  test(
    'Repository batches owner-scoped writes and awaits server acknowledgement',
    () async {
      final firestore = RecordingFirestore();
      final repository = FirestoreTaskRepository(firestore);
      final tasks = [
        Task(
          id: 'a',
          title: 'Read',
          dueDate: DateTime(2026, 9, 23),
          notes: 'Chapter 2',
        ),
        Task(id: 'b', title: 'Write', dueDate: DateTime(2026, 9, 25)),
      ];
      var finished = false;
      final save = repository
          .saveTasks('alice', tasks)
          .then((_) => finished = true);
      await Future<void>.delayed(Duration.zero);
      expect(finished, isFalse);
      expect(firestore.commits, 1);
      expect(firestore.writes.keys, [
        'users/alice/tasks/a',
        'users/alice/tasks/b',
      ]);
      expect(firestore.writes['users/alice/tasks/a'], tasks.first.toMap());
      firestore.acknowledgement.complete();
      await save;
      await repository.saveTasks('alice', tasks);
      expect(firestore.writes, hasLength(2));
      expect(firestore.commits, 2);
    },
  );

  test(
    'Repository propagates permission failures for the review screen to retry',
    () async {
      final firestore = RecordingFirestore();
      final repository = FirestoreTaskRepository(firestore);
      final save = repository.saveTasks('alice', [
        Task(id: 'a', title: 'Read', dueDate: DateTime(2026)),
      ]);
      final result = expectLater(save, throwsA(isA<FirebaseException>()));
      firestore.acknowledgement.completeError(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      await result;
    },
  );
}
