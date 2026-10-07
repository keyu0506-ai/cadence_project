import 'dart:typed_data';
import '../../tasks/task.dart';
import 'task_extractor.dart';

// Deterministic fixture for widget tests; production uses CloudTaskExtractor.
class DemoTaskExtractor implements TaskExtractor {
  static int _sequence = 0;

  @override
  Future<List<TaskDraft>> extract(String text, {Uint8List? imageBytes}) async {
    if (text.trim().isEmpty && (imageBytes == null || imageBytes.isEmpty)) {
      return [];
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final today = taskDate(DateTime.now());
    final batch = '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
    return [
      TaskDraft(
        id: '$batch-1',
        title: 'Read Ch. 9 & annotate (pp. 142–161)',
        dueDate: today,
        subject: 'AP Bio',
      ),
      TaskDraft(
        id: '$batch-2',
        title: 'Respiration Lab Report',
        subject: 'AP Bio',
        dueDate: DateTime(today.year, today.month, today.day + 3),
      ),
      TaskDraft(
        id: '$batch-3',
        title: 'Vocab quiz — 15 terms',
        dueDate: DateTime(today.year, today.month, today.day + 4),
        subject: 'AP Bio',
      ),
      TaskDraft(
        id: '$batch-4',
        title: 'Optional: extra-credit diagram',
        subject: 'AP Bio',
      ),
    ];
  }
}
