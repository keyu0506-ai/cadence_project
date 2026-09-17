import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:cadence_project/features/auth/providers/auth_providers.dart';
import 'package:cadence_project/features/capture/presentation/screens/capture_screen.dart';
import 'package:cadence_project/features/home/presentation/screens/home_screen.dart';
import 'package:cadence_project/features/tasks/task.dart';
import 'package:cadence_project/features/tasks/tasks_provider.dart';

void main() {
  test('Confirmation validates drafts and normalizes saved values', () {
    expect(
      () => const TaskDraft(id: '1', title: 'Read').confirm(),
      throwsStateError,
    );
    expect(
      () => TaskDraft(id: '1', title: '  ', dueDate: DateTime(2026)).confirm(),
      throwsStateError,
    );
    final task = TaskDraft(
      id: '1',
      title: ' Read ',
      dueDate: DateTime(2026, 9, 16, 18),
      notes: ' chapter 1 ',
    ).confirm();
    expect(task.title, 'Read');
    expect(task.notes, 'chapter 1');
    expect(task.dueDate, DateTime(2026, 9, 16));
  });

  test('Repeated task IDs are saved once', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    addTearDown(container.dispose);

    final task = Task(id: '1', title: 'Read', dueDate: DateTime(2026));
    container.read(tasksProvider.notifier).addTasks([task, task]);
    container.read(tasksProvider.notifier).addTasks([task]);
    expect(container.read(tasksProvider), hasLength(1));
  });

  testWidgets(
    'Demo extraction reviews, validates, deselects and saves edited notes',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      addTearDown(container.dispose);

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
      addTearDown(router.dispose);
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
        'Read today and complete unit 7 later',
      );
      await tester.pump();
      await tester.tap(find.text('Extract tasks'));
      await tester.pump();
      expect(find.text('Extracting…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(container.read(tasksProvider), isEmpty);
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.ensureVisible(find.text('Add 2 tasks to schedule'));
      await tester.tap(find.text('Add 2 tasks to schedule'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a task title'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Edited reading',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Remember chapter 2',
      );
      await tester.ensureVisible(find.byType(CheckboxListTile).last);
      await tester.tap(find.byType(CheckboxListTile).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Add 1 task to schedule'));
      await tester.tap(find.text('Add 1 task to schedule'));
      await tester.pumpAndSettle();
      expect(find.text("Today's Plan"), findsOneWidget);
      expect(find.text('Edited reading'), findsOneWidget);
      expect(find.text('Remember chapter 2'), findsOneWidget);
      expect(find.text('No upcoming deadlines'), findsOneWidget);
      final saved = container.read(tasksProvider);
      expect(saved, hasLength(1));
      expect(saved.single.title, 'Edited reading');
      expect(saved.single.notes, 'Remember chapter 2');
      expect(saved.single.dueDate, taskDate(DateTime.now()));
    },
  );
}
