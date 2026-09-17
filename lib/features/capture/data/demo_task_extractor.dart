import '../../tasks/task.dart';

class DemoTaskExtractor {
  static int _sequence = 0;

  Future<List<TaskDraft>> extract(String text) async {
    if (text.trim().isEmpty) return [];
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final today = taskDate(DateTime.now());
    final batch = '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
    return [
      TaskDraft(id: '$batch-1', title: 'Read The Hobbit', dueDate: today),
      TaskDraft(
        id: '$batch-2',
        title: 'Complete Unit 7',
        dueDate: DateTime(today.year, today.month, today.day + 3),
      ),
    ];
  }
}
