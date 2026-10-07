DateTime taskDate(DateTime date) => DateTime(date.year, date.month, date.day);

class TaskDraft {
  const TaskDraft({
    required this.id,
    required this.title,
    this.dueDate,
    this.notes,
    this.subject,
  });
  final String id;
  final String title;
  final DateTime? dueDate;
  final String? notes;
  final String? subject;

  Task confirm() {
    if (title.trim().isEmpty || dueDate == null) {
      throw StateError('A title and due date are required.');
    }
    return Task(
      id: id,
      title: title.trim(),
      dueDate: dueDate!,
      notes: notes,
      subject: subject,
    );
  }
}

class Task {
  Task({
    required this.id,
    required String title,
    required DateTime dueDate,
    String? notes,
    String? subject,
  }) : title = title.trim(),
       dueDate = taskDate(dueDate),
       notes = notes == null || notes.trim().isEmpty ? null : notes.trim(),
       subject = subject == null || subject.trim().isEmpty
           ? null
           : subject.trim() {
    if (this.title.isEmpty) throw ArgumentError('A title is required.');
  }
  final String id;
  final String title;
  final DateTime dueDate;
  final String? notes;
  final String? subject;
  Map<String, dynamic> toMap() => {
    'title': title,
    'dueDate':
        '${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
    'notes': notes,
    'subject': subject,
  };

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    final title = data['title'];
    final date = data['dueDate'];
    final notes = data['notes'];
    final subject = data['subject'];
    if (title is! String ||
        title.trim().isEmpty ||
        date is! String ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        (notes != null && notes is! String) ||
        (subject != null && subject is! String)) {
      throw const FormatException('Invalid saved task.');
    }
    final parsed = DateTime.tryParse(date);
    if (parsed == null) throw const FormatException('Invalid task date.');
    final task = Task(
      id: id,
      title: title,
      dueDate: parsed,
      notes: notes as String?,
      subject: subject as String?,
    );
    if (task.toMap()['dueDate'] != date) {
      throw const FormatException('Invalid task date.');
    }
    return task;
  }
}
