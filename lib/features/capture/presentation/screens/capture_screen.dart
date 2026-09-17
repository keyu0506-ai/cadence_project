import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/demo_task_extractor.dart';
import '../../../tasks/task.dart';
import '../../../tasks/tasks_provider.dart';

enum _CaptureMode { photo, text }

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _textController = TextEditingController();
  var _mode = _CaptureMode.photo;
  final _extractor = DemoTaskExtractor();
  final _formKey = GlobalKey<FormState>();
  List<TaskDraft> _drafts = [];
  final Set<String> _selected = {};
  bool _extracting = false;
  bool _confirmed = false;

  Future<void> _extract() async {
    if (_extracting || _confirmed) return;
    FocusScope.of(context).unfocus();
    setState(() => _extracting = true);
    final drafts = await _extractor.extract(_textController.text);
    if (!mounted) return;
    setState(() {
      _drafts = drafts;
      _selected
        ..clear()
        ..addAll(drafts.map((draft) => draft.id));
      _extracting = false;
    });
  }

  void _confirm() {
    if (_confirmed || _selected.isEmpty || !_formKey.currentState!.validate()) {
      return;
    }
    final selected = _drafts
        .where((draft) => _selected.contains(draft.id))
        .toList();
    if (selected.any((draft) => draft.dueDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a due date for each selected task.'),
        ),
      );
      return;
    }
    setState(() => _confirmed = true);
    ref
        .read(tasksProvider.notifier)
        .addTasks(selected.map((draft) => draft.confirm()));
    context.go('/home');
  }

  Widget _review() {
    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8946F5)),
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Demo found ${_drafts.length} tasks',
                style: const TextStyle(
                  color: Color(0xFF17112F),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < _drafts.length; index++)
                _draftCard(index),
              FilledButton(
                onPressed: _selected.isEmpty || _confirmed ? null : _confirm,
                child: Text(
                  'Add ${_selected.length} ${_selected.length == 1 ? 'task' : 'tasks'} to schedule',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demo tasks are temporary and clear on refresh, restart, or sign-out.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF766C8D)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _draftCard(int index) {
    final draft = _drafts[index];
    final selected = _selected.contains(draft.id);
    return Card(
      key: ValueKey(draft.id),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include task'),
              value: selected,
              onChanged: (value) => setState(() {
                if (value == true) {
                  _selected.add(draft.id);
                } else {
                  _selected.remove(draft.id);
                }
              }),
            ),
            TextFormField(
              initialValue: draft.title,
              decoration: const InputDecoration(labelText: 'Task title'),
              validator: (value) =>
                  _selected.contains(draft.id) &&
                      (value == null || value.trim().isEmpty)
                  ? 'Enter a task title'
                  : null,
              onChanged: (value) {
                final current = _drafts[index];
                _drafts[index] = TaskDraft(
                  id: current.id,
                  title: value,
                  dueDate: current.dueDate,
                  notes: current.notes,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: draft.notes,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              onChanged: (value) {
                final current = _drafts[index];
                _drafts[index] = TaskDraft(
                  id: current.id,
                  title: current.title,
                  dueDate: current.dueDate,
                  notes: value,
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                draft.dueDate == null
                    ? 'Choose a date'
                    : MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(draft.dueDate!),
              ),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: draft.dueDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (!mounted || date == null) return;
                setState(() {
                  final current = _drafts[index];
                  _drafts[index] = TaskDraft(
                    id: current.id,
                    title: current.title,
                    dueDate: date,
                    notes: current.notes,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF131027), Color(0xFF281A50)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Back',
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.12,
                                ),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                'Capture Note',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 48,
                              child: Icon(
                                Icons.bolt_rounded,
                                color: Color(0xFFAA87FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 320,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF251D43),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF65518F)),
                          ),
                          child: _mode == _CaptureMode.photo
                              ? const _PhotoPlaceholder()
                              : TextField(
                                  controller: _textController,
                                  onChanged: (_) => setState(() {}),
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Type or paste notes here…',
                                    hintStyle: TextStyle(
                                      color: Color(0xFFAAA1C2),
                                    ),
                                    contentPadding: EdgeInsets.all(20),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        SegmentedButton<_CaptureMode>(
                          segments: const [
                            ButtonSegment(
                              value: _CaptureMode.photo,
                              icon: Icon(Icons.photo_camera_rounded),
                              label: Text('Photo'),
                            ),
                            ButtonSegment(
                              value: _CaptureMode.text,
                              icon: Icon(Icons.keyboard_rounded),
                              label: Text('Text'),
                            ),
                          ],
                          selected: {_mode},
                          showSelectedIcon: false,
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? Colors.white
                                  : const Color(0xFFB5ABCF),
                            ),
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? const Color(0xFF5B507B)
                                  : const Color(0xFF382D58),
                            ),
                            side: const WidgetStatePropertyAll(BorderSide.none),
                          ),
                          onSelectionChanged: (selection) {
                            FocusScope.of(context).unfocus();
                            setState(() => _mode = selection.single);
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed:
                                _mode == _CaptureMode.text &&
                                    _textController.text.trim().isNotEmpty &&
                                    !_extracting &&
                                    !_confirmed &&
                                    _drafts.isEmpty
                                ? _extract
                                : null,
                            style: FilledButton.styleFrom(
                              disabledBackgroundColor: const Color(0xFF69429E),
                              disabledForegroundColor: const Color(0xFFD7CCE9),
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: Text(
                              _extracting ? 'Extracting…' : 'Extract tasks',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Demo extraction · returns sample tasks, not AI results',
                          style: TextStyle(
                            color: Color(0xFFB5ABCF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_drafts.isNotEmpty)
                    _review()
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 80,
                        horizontal: 24,
                      ),
                      child: Text(
                        'No tasks detected yet',
                        style: TextStyle(
                          color: Color(0xFF9188A7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: Color(0xFFB695FF),
          ),
          SizedBox(height: 20),
          Text(
            'Upload image',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Image upload coming soon',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFAAA1C2)),
          ),
        ],
      ),
    );
  }
}
