DateTime taskDate(DateTime date) => DateTime(date.year, date.month, date.day);

class TaskDraft {
  const TaskDraft({
    required this.id,
    required this.title,
    this.dueDate,
    this.notes,
  });
  final String id;
  final String title;
  final DateTime? dueDate;
  final String? notes;

  Task confirm() {
    if (title.trim().isEmpty || dueDate == null) {
      throw StateError('A title and due date are required.');
    }
    return Task(id: id, title: title.trim(), dueDate: dueDate!, notes: notes);
  }
}

class Task {
  Task({
    required this.id,
    required String title,
    required DateTime dueDate,
    String? notes,
  }) : title = title.trim(),
       dueDate = taskDate(dueDate),
       notes = notes == null || notes.trim().isEmpty ? null : notes.trim() {
    if (this.title.isEmpty) throw ArgumentError('A title is required.');
  }
  final String id;
  final String title;
  final DateTime dueDate;
  final String? notes;
}
