import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/task_extractor.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../data/local_image_picker.dart';
import '../widgets/photo_input.dart';
import '../widgets/task_draft_card.dart';
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
  final _scrollController = ScrollController();
  var _mode = _CaptureMode.photo;
  String? _extractionError;
  bool _hasExtracted = false;
  final _formKey = GlobalKey<FormState>();
  List<TaskDraft> _drafts = [];
  final Set<String> _selected = {};
  bool _extracting = false;
  bool _confirmed = false;
  String? _saveError;
  NoteImage? _image;
  bool _pickingImage = false;
  String? _imageError;
  int _imageRequest = 0;

  Future<void> _pickImage() async {
    if (_pickingImage || _extracting) return;
    final request = ++_imageRequest;
    setState(() {
      _pickingImage = true;
      _imageError = null;
    });
    try {
      final image = await ref.read(localImagePickerProvider).pick();
      if (!mounted || request != _imageRequest) return;
      if (image != null) setState(() => _image = image);
    } catch (error) {
      if (mounted && request == _imageRequest) {
        setState(
          () => _imageError = error is FormatException
              ? error.message
              : 'Could not open the image. Please try again.',
        );
      }
    } finally {
      if (mounted && request == _imageRequest) {
        setState(() => _pickingImage = false);
      }
    }
  }

  Future<void> _extract() async {
    if (_extracting || _confirmed) return;
    final userId = ref.read(taskUserIdProvider);
    if (userId == null) {
      setState(() => _extractionError = 'Please sign in to extract tasks.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _extracting = true;
      _extractionError = null;
      _hasExtracted = false;
    });
    try {
      final drafts = await ref
          .read(taskExtractorProvider)
          .extract(
            _mode == _CaptureMode.text ? _textController.text : '',
            imageBytes: _mode == _CaptureMode.photo ? _image?.bytes : null,
          );
      if (!mounted || ref.read(taskUserIdProvider) != userId) return;
      setState(() {
        _drafts = drafts;
        _selected
          ..clear()
          ..addAll(
            drafts
                .where((draft) => draft.dueDate != null)
                .map((draft) => draft.id),
          );
        _hasExtracted = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[TaskExtraction] review failed type=${error.runtimeType}');
        debugPrintStack(stackTrace: stack, maxFrames: 8);
      }
      if (!mounted || ref.read(taskUserIdProvider) != userId) return;
      setState(
        () => _extractionError = switch (error) {
          FirebaseFunctionsException(code: 'unauthenticated') =>
            'Please sign in again to extract tasks.',
          FirebaseFunctionsException(
            code: 'resource-exhausted',
            details: {'reason': 'quota'},
          ) =>
            'AI extraction is unavailable because the service has no API credits. Please contact the app owner.',
          FirebaseFunctionsException(code: 'resource-exhausted') =>
            'Extraction is busy. Please try again later.',
          FirebaseFunctionsException(code: 'deadline-exceeded') =>
            'Extraction timed out. Your input is still here; please retry.',
          FirebaseFunctionsException(code: 'failed-precondition') =>
            'Could not read tasks. Try a clearer image or a smaller section.',
          FirebaseFunctionsException(code: 'invalid-argument') =>
            'Check your image or notes and try again.',
          FirebaseFunctionsException(code: 'internal') =>
            'The extraction service encountered an error. Please retry. If it persists, check the function logs.',
          FirebaseFunctionsException(code: 'unavailable') =>
            'Could not reach the extraction service. Check your connection and retry.',
          FormatException() =>
            'The extraction service returned invalid task data. Please retry.',
          _ =>
            'Could not extract tasks. Your input is still here. Check your connection and retry.',
        },
      );
    } finally {
      if (mounted) setState(() => _extracting = false);
    }
  }

  Future<void> _confirm() async {
    if (_confirmed || _selected.isEmpty || !_formKey.currentState!.validate()) {
      return;
    }
    final selected = _drafts
        .where((draft) => _selected.contains(draft.id))
        .toList();
    if (selected.any((draft) => draft.title.trim().isEmpty)) {
      setState(() => _saveError = 'Enter a task title for each selected task.');
      return;
    }
    if (selected.any((draft) => draft.dueDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a due date for each selected task.'),
        ),
      );
      return;
    }
    final userId = ref.read(taskUserIdProvider);
    if (userId == null) {
      setState(() => _saveError = 'Please sign in before saving tasks.');
      return;
    }
    setState(() {
      _confirmed = true;
      _saveError = null;
    });
    try {
      await ref
          .read(taskRepositoryProvider)
          .saveTasks(userId, selected.map((draft) => draft.confirm()).toList());
      if (!mounted) return;
      if (ref.read(taskUserIdProvider) == userId) context.go('/home');
    } on TimeoutException {
      if (mounted) {
        setState(
          () => _saveError =
              'Save not confirmed. Check your connection and retry. The request may still finish; retrying these tasks will not duplicate them.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _saveError =
              'Could not save tasks. Your edits are still here. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _confirmed = false);
    }
  }

  Widget _review() {
    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8946F5)),
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back to Home'),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'AI found ',
                            style: TextStyle(color: Color(0xFF251E3D)),
                          ),
                          TextSpan(
                            text: '${_drafts.length} to-dos',
                            style: const TextStyle(color: Color(0xFF9255F9)),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEE6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Review & add',
                      style: TextStyle(
                        color: Color(0xFF7B3BE5),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(
                    Icons.description_rounded,
                    color: Color(0xFF9255F9),
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'AI-extracted tasks · Check details before saving',
                      style: TextStyle(color: Color(0xFF9188AC), fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < _drafts.length; index++)
                TaskDraftCard(
                  key: ValueKey(_drafts[index].id),
                  draft: _drafts[index],
                  selected: _selected.contains(_drafts[index].id),
                  onSelected: (value) => setState(() {
                    if (value) {
                      _selected.add(_drafts[index].id);
                    } else {
                      _selected.remove(_drafts[index].id);
                    }
                  }),
                  onChanged: (draft) => setState(() => _drafts[index] = draft),
                ),
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _saveError!,
                    style: const TextStyle(color: Color(0xFFB3261E)),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 4, bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3D7FC)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFF7B3BE5)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Review each task’s subject and deadline. Tap the pencil to edit details. Selected tasks need a date and will appear on Home after saving.',
                        style: TextStyle(color: Color(0xFF766C8D), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9255F9), Color(0xFF6226C5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed:
                      _selected.isEmpty ||
                          _confirmed ||
                          _drafts.any(
                            (draft) =>
                                _selected.contains(draft.id) &&
                                draft.dueDate == null,
                          )
                      ? null
                      : _confirm,
                  icon: const Icon(Icons.event_available_rounded),
                  label: Text(
                    _confirmed
                        ? 'Saving…'
                        : 'Add ${_selected.length} to my schedule',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Confirmed tasks are saved to your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF766C8D)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(taskUserIdProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          _drafts = [];
          _selected.clear();
          _textController.clear();
          _imageRequest++;
          _extractionError = null;
          _hasExtracted = false;
          _image = null;
          _pickingImage = false;
          _imageError = null;
          _saveError = null;
        });
      }
    });
    return PopScope(
      canPop: !_confirmed,
      child: AbsorbPointer(
        absorbing: _confirmed || _extracting,
        child: Scaffold(
          backgroundColor: const Color(0xFFF3EEFF),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      if (_drafts.isEmpty)
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
                                  border: Border.all(
                                    color: const Color(0xFF65518F),
                                  ),
                                ),
                                child: _mode == _CaptureMode.photo
                                    ? PhotoInput(
                                        image: _image,
                                        busy: _pickingImage,
                                        onChoose: _pickImage,
                                        onRemove: () {
                                          if (!_extracting) {
                                            setState(() {
                                              _image = null;
                                              _imageError = null;
                                            });
                                          }
                                        },
                                      )
                                    : TextField(
                                        controller: _textController,
                                        maxLength: 20000,
                                        onChanged: (_) => setState(() {}),
                                        expands: true,
                                        maxLines: null,
                                        minLines: null,
                                        keyboardType: TextInputType.multiline,
                                        textAlignVertical:
                                            TextAlignVertical.top,
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
                              if (_mode == _CaptureMode.photo &&
                                  _imageError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    _imageError!,
                                    style: const TextStyle(
                                      color: Color(0xFFFFB4AB),
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
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              WidgetState.selected,
                                            )
                                            ? Colors.white
                                            : const Color(0xFFB5ABCF),
                                      ),
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              WidgetState.selected,
                                            )
                                            ? const Color(0xFF5B507B)
                                            : const Color(0xFF382D58),
                                      ),
                                  side: const WidgetStatePropertyAll(
                                    BorderSide.none,
                                  ),
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
                                      (_mode == _CaptureMode.text
                                              ? _textController.text
                                                    .trim()
                                                    .isNotEmpty
                                              : _image != null) &&
                                          !_pickingImage &&
                                          !_extracting &&
                                          !_confirmed &&
                                          _drafts.isEmpty
                                      ? _extract
                                      : null,
                                  style: FilledButton.styleFrom(
                                    disabledBackgroundColor: const Color(
                                      0xFF69429E,
                                    ),
                                    disabledForegroundColor: const Color(
                                      0xFFD7CCE9,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.auto_awesome,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _extracting
                                        ? 'Extracting…'
                                        : 'Extract tasks',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'AI analyzes your input. Review tasks before saving.',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 80,
                            horizontal: 24,
                          ),
                          child: Text(
                            _extractionError ??
                                (_extracting
                                    ? 'Analyzing your input…'
                                    : _hasExtracted
                                    ? 'No tasks found. Try a clearer image or different notes.'
                                    : 'No tasks detected yet'),
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
        ),
      ),
    );
  }
}
