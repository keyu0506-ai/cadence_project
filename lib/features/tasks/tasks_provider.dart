import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers/auth_providers.dart';
import 'task.dart';

final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    // Rebuild and clear temporary tasks whenever the signed-in identity changes.
    ref.watch(authStateProvider.select((auth) => auth.asData?.value?.uid));
    return const [];
  }

  void addTasks(Iterable<Task> tasks) {
    final byId = {for (final task in state) task.id: task};
    for (final task in tasks) {
      byId.putIfAbsent(task.id, () => task);
    }
    state = List.unmodifiable(byId.values);
  }
}
