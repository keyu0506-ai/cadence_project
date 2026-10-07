import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

abstract interface class TaskRepository {
  Stream<List<Task>> watchTasks(String userId);
  Future<void> saveTasks(String userId, List<Task> tasks);
}

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tasks(String userId) {
    if (userId.isEmpty) throw ArgumentError('A signed-in user is required.');
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Stream<List<Task>> watchTasks(String userId) =>
      _tasks(userId).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .toList(growable: false),
      );

  @override
  Future<void> saveTasks(String userId, List<Task> tasks) async {
    final collection = _tasks(userId);
    if (tasks.isEmpty) return;
    final batch = _firestore.batch();
    // Stable document IDs make retries safe after a lost acknowledgement.
    for (final task in {for (final task in tasks) task.id: task}.values) {
      batch.set(collection.doc(task.id), task.toMap());
    }
    await batch.commit().timeout(const Duration(seconds: 20));
  }
}
