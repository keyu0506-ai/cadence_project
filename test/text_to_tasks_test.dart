import 'package:cadence_project/features/capture/data/task_extractor.dart';
import 'package:cadence_project/features/capture/data/demo_task_extractor.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:cadence_project/features/auth/providers/auth_providers.dart';
import 'package:cadence_project/features/capture/presentation/screens/capture_screen.dart';
import 'package:cadence_project/features/home/presentation/screens/home_screen.dart';
import 'package:cadence_project/features/tasks/task.dart';
import 'package:cadence_project/features/tasks/task_repository.dart';
import 'package:cadence_project/features/tasks/tasks_provider.dart';

class TestIdentity extends Notifier<String?> {
  @override
  String? build() => 'alice';
  void change(String? id) => state = id;
}

final identityProvider = NotifierProvider<TestIdentity, String?>(
  TestIdentity.new,
);

// A controlled repository lets UI tests exercise acknowledgements and failures
// without Firebase credentials. Live Firestore checks are documented separately.
class TestTaskRepository implements TaskRepository {
  final rows = <String, Map<String, Task>>{};
  final changes = StreamController<void>.broadcast();
  final attempts = <List<Task>>[];
  Completer<void>? saveGate;
  bool failNextSave = false;
  bool failReads = false;

  @override
  Stream<List<Task>> watchTasks(String userId) async* {
    if (failReads) throw StateError('Read failed');
    yield rows[userId]?.values.toList() ?? [];
    await for (final _ in changes.stream) {
      yield rows[userId]?.values.toList() ?? [];
    }
  }

  @override
  Future<void> saveTasks(String userId, List<Task> tasks) async {
    attempts.add(tasks);
    if (saveGate != null) await saveGate!.future;
    if (failNextSave) {
      failNextSave = false;
      throw StateError('Save failed');
    }
    final userRows = rows.putIfAbsent(userId, () => {});
    for (final task in tasks) {
      userRows[task.id] = Task.fromMap(task.id, task.toMap());
    }
    changes.add(null);
  }
}

ProviderContainer containerFor(TestTaskRepository repository) =>
    ProviderContainer(
      overrides: [
        taskExtractorProvider.overrideWithValue(DemoTaskExtractor()),
        authStateProvider.overrideWith((ref) => const Stream.empty()),
        taskUserIdProvider.overrideWith((ref) => ref.watch(identityProvider)),
        taskRepositoryProvider.overrideWithValue(repository),
      ],
    );

void main() {
  test('Confirmation validates drafts and serializes date-only values', () {
    expect(
      () => const TaskDraft(id: '1', title: 'Read').confirm(),
      throwsStateError,
    );
    expect(
      () => TaskDraft(id: '1', title: ' ', dueDate: DateTime(2026)).confirm(),
      throwsStateError,
    );
    final task = TaskDraft(
      id: '1',
      title: ' Read ',
      dueDate: DateTime(2026, 9, 16, 18),
      notes: ' chapter 1 ',
      subject: ' AP Bio ',
    ).confirm();
    expect(task.toMap(), {
      'title': 'Read',
      'dueDate': '2026-09-16',
      'notes': 'chapter 1',
      'subject': 'AP Bio',
    });
    final restored = Task.fromMap('1', task.toMap());
    expect(restored.id, task.id);
    expect(restored.dueDate, DateTime(2026, 9, 16));
    expect(restored.notes, 'chapter 1');
    expect(restored.subject, 'AP Bio');
    expect(
      Task.fromMap('legacy', {
        'title': 'Old task',
        'dueDate': '2026-09-16',
        'notes': null,
      }).subject,
      isNull,
    );
    expect(
      Task(
        id: '2',
        title: 'Read',
        dueDate: DateTime(2026),
        notes: ' ',
      ).toMap()['notes'],
      isNull,
    );
    expect(
      () => Task.fromMap('1', {'title': 'Read', 'dueDate': '2026-02-30'}),
      throwsFormatException,
    );
    expect(
      () => Task.fromMap('1', {'title': 'Read', 'dueDate': 'tomorrow'}),
      throwsFormatException,
    );
  });

  test(
    'Account switches and sign-out never expose the previous task list',
    () async {
      final repository = TestTaskRepository();
      final task = Task(id: '1', title: 'Alice task', dueDate: DateTime(2026));
      repository.rows['alice'] = {'1': task};
      final container = containerFor(repository);
      final subscription = container.listen(tasksProvider, (_, _) {});
      addTearDown(() {
        subscription.close();
        container.dispose();
        repository.changes.close();
      });
      await container.read(userTasksProvider('alice').future);
      expect(
        container.read(tasksProvider).asData!.value.single.title,
        'Alice task',
      );
      container.read(identityProvider.notifier).change('bob');
      expect(container.read(tasksProvider).asData?.value, isNull);
      await container.read(userTasksProvider('bob').future);
      expect(container.read(tasksProvider).asData!.value, isEmpty);
      container.read(identityProvider.notifier).change(null);
      expect(container.read(tasksProvider).asData!.value, isEmpty);
      container.read(identityProvider.notifier).change('alice');
      await container.read(userTasksProvider('alice').future);
      expect(container.read(tasksProvider).asData!.value.single.id, '1');
    },
  );

  testWidgets(
    'Review preserves edits on failure, awaits save, and retries the same IDs',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = TestTaskRepository()..failNextSave = true;
      final container = containerFor(repository);
      final router = GoRouter(
        initialLocation: '/capture',
        routes: [
          GoRoute(path: '/capture', builder: (_, _) => const CaptureScreen()),
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(body: HomeScreen()),
          ),
        ],
      );
      addTearDown(() {
        router.dispose();
        container.dispose();
        repository.changes.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.tap(find.text('Text'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Read today and finish later',
      );
      await tester.pump();
      await tester.tap(find.text('Extract tasks'));
      await tester.pump();
      expect(find.text('Extracting…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(repository.attempts, isEmpty);
      expect(find.text('Deadline required'), findsOneWidget);
      await tester.ensureVisible(find.byType(Checkbox).last);
      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();
      final addButton = find.widgetWithText(FilledButton, 'Add 4 to my schedule');
      expect(tester.widget<FilledButton>(addButton).onPressed, isNull);
      expect(repository.attempts, isEmpty);
      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Edit task').first);
      await tester.tap(find.byTooltip('Edit task').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.ensureVisible(find.text('Add 3 to my schedule'));
      await tester.tap(find.text('Add 3 to my schedule'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a task title'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Edited reading',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Remember chapter 2',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'English');
      await tester.ensureVisible(find.byType(Checkbox).at(1));
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Checkbox).at(2));
      await tester.tap(find.byType(Checkbox).at(2));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Add 1 to my schedule'));
      await tester.tap(find.text('Add 1 to my schedule'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not save tasks.'), findsOneWidget);
      expect(find.text('Remember chapter 2'), findsOneWidget);
      expect(repository.rows, isEmpty);
      repository.saveGate = Completer<void>();
      await tester.ensureVisible(find.text('Add 1 to my schedule'));
      await tester.tap(find.text('Add 1 to my schedule'));
      await tester.pump();
      expect(find.text('Saving…'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/capture');
      // Repeated activation while the acknowledgement is pending is disabled.
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Saving…'),
      );
      expect(saveButton.onPressed, isNull);
      expect(repository.attempts, hasLength(2));
      repository.saveGate!.complete();
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/home');
      expect(find.text('Edited reading'), findsOneWidget);
      expect(find.text('Remember chapter 2'), findsOneWidget);
      expect(find.text('No upcoming deadlines'), findsOneWidget);
      expect(
        repository.attempts[0].single.id,
        repository.attempts[1].single.id,
      );
      expect(repository.rows['alice'], hasLength(1));
      expect(repository.rows['alice']!.values.single.subject, 'English');
      expect(find.text('English'), findsOneWidget);
      expect(
        container.read(tasksProvider).asData!.value.single.dueDate,
        taskDate(DateTime.now()),
      );
    },
  );

  testWidgets(
    'Home loads, groups saved tasks, and recovers from a read failure',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final today = taskDate(DateTime.now());
      final repository = TestTaskRepository()..failReads = true;
      repository.rows['alice'] = {
        'today': Task(id: 'today', title: 'Due now', dueDate: today),
        'later': Task(
          id: 'later',
          title: 'Due later',
          dueDate: DateTime(today.year, today.month, today.day + 3),
        ),
      };
      final container = containerFor(repository);
      addTearDown(() {
        container.dispose();
        repository.changes.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: HomeScreen())),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      await tester.pumpAndSettle();
      expect(
        find.text('Could not load tasks. Please try again.'),
        findsNWidgets(2),
      );
      repository.failReads = false;
      await tester.ensureVisible(find.text('Retry').first);
      await tester.tap(find.text('Retry').first);
      await tester.pumpAndSettle();
      expect(find.text('Due now'), findsOneWidget);
      expect(find.text('Due later'), findsOneWidget);
      expect(
        find.text('Could not load tasks. Please try again.'),
        findsNothing,
      );
    },
  );
}
