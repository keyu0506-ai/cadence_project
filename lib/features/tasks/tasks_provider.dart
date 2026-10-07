import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers/auth_providers.dart';
import 'task.dart';
import 'task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirestoreTaskRepository(FirebaseFirestore.instance);
});

final taskUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.isLoading || auth.hasError ? null : auth.asData?.value?.uid;
});

final userTasksProvider = StreamProvider.autoDispose.family<List<Task>, String>(
  (ref, userId) {
    return ref.watch(taskRepositoryProvider).watchTasks(userId);
  },
);

// Each account has its own stream, so switching accounts cannot display the
// previous user's cached AsyncData while the new tasks are loading.
final tasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final userId = ref.watch(taskUserIdProvider);
  if (userId == null) return const AsyncData([]);
  return ref.watch(userTasksProvider(userId));
});
