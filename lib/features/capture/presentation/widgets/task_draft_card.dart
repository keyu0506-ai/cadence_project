import 'package:flutter/material.dart';
import '../../../tasks/task.dart';

class TaskDraftCard extends StatefulWidget {
  const TaskDraftCard({
    super.key,
    required this.draft,
    required this.selected,
    required this.onSelected,
    required this.onChanged,
  });
  final TaskDraft draft;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final ValueChanged<TaskDraft> onChanged;

  @override
  State<TaskDraftCard> createState() => _TaskDraftCardState();
}

class _TaskDraftCardState extends State<TaskDraftCard> {
  bool _editing = false;

  void _update({
    String? title,
    String? subject,
    String? notes,
    DateTime? date,
  }) {
    final draft = widget.draft;
    widget.onChanged(
      TaskDraft(
        id: draft.id,
        title: title ?? draft.title,
        subject: subject ?? draft.subject,
        notes: notes ?? draft.notes,
        dueDate: date ?? draft.dueDate,
      ),
    );
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.draft.dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (mounted && date != null) _update(date: date);
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final subject = draft.subject?.trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F0733),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Include ${draft.title}',
                child: Checkbox(
                  value: widget.selected,
                  onChanged: (value) => widget.onSelected(value ?? false),
                  activeColor: const Color(0xFF773BE3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  side: const BorderSide(color: Color(0xFFDDD5F5), width: 2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    draft.title.trim().isEmpty ? 'Untitled task' : draft.title,
                    style: const TextStyle(
                      color: Color(0xFF251E3D),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: _editing ? 'Done editing task' : 'Edit task',
                onPressed: () => setState(() => _editing = !_editing),
                icon: Icon(
                  _editing ? Icons.check_rounded : Icons.edit_outlined,
                  size: 18,
                  color: const Color(0xFF8650E8),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _Badge(
                  label: subject == null || subject.isEmpty
                      ? 'Add subject'
                      : subject,
                  icon: Icons.science_rounded,
                  color: const Color(0xFF7B3BE5),
                  background: const Color(0xFFEEE6FF),
                  onTap: () => setState(() => _editing = true),
                ),
                _Badge(
                  label: draft.dueDate == null
                      ? 'Deadline required'
                      : 'Due ${MaterialLocalizations.of(context).formatShortDate(draft.dueDate!)}',
                  icon: draft.dueDate == null
                      ? Icons.error_outline_rounded
                      : Icons.calendar_today_rounded,
                  color: draft.dueDate == null
                      ? const Color(0xFFD93260)
                      : const Color(0xFFD93260),
                  background: draft.dueDate == null
                      ? const Color(0xFFF0EDF7)
                      : const Color(0xFFFFE5EA),
                  onTap: _chooseDate,
                ),
              ],
            ),
          ),
          if (_editing)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 4, 0),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: draft.title,
                    maxLength: 200,
                    decoration: const InputDecoration(labelText: 'Task title'),
                    validator: (value) =>
                        widget.selected &&
                            (value == null || value.trim().isEmpty)
                        ? 'Enter a task title'
                        : null,
                    onChanged: (value) => _update(title: value),
                  ),
                  TextFormField(
                    initialValue: draft.subject,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Subject (optional)',
                      hintText: 'e.g. AP Bio',
                    ),
                    onChanged: (value) => _update(subject: value),
                  ),
                  TextFormField(
                    initialValue: draft.notes,
                    maxLength: 5000,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                    onChanged: (value) => _update(notes: value),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
