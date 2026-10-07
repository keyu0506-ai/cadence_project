import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadence_project/features/capture/data/task_extractor.dart';
import 'package:cadence_project/features/capture/presentation/screens/capture_screen.dart';
import 'package:cadence_project/features/tasks/tasks_provider.dart';

void main() {
  test(
    'Parses AI drafts with nullable dates and sends image plus local date context',
    () async {
      Map<String, Object>? sent;
      final extractor = CloudTaskExtractor(
        call: (input) async {
          sent = input;
          return {
            'tasks': [
              {
                'title': 'Read chapter 3',
                'subject': 'Biology',
                'dueDate': '2026-10-12',
                'notes': null,
              },
              {
                'title': 'Write essay',
                'subject': null,
                'dueDate': null,
                'notes': 'Due next week',
              },
            ],
          };
        },
      );
      final drafts = await extractor.extract(
        '',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(sent!['imageBase64'], 'AQID');
      expect(sent!.containsKey('text'), isFalse);
      expect(sent!['utcOffsetMinutes'], isA<int>());
      expect(drafts.first.dueDate, DateTime(2026, 10, 12));
      expect(drafts.last.dueDate, isNull);
      expect(drafts.first.id, isNot(drafts.last.id));
    },
  );
  test('Rejects malformed AI task data', () async {
    for (final response in [
      {'tasks': 'wrong'},
      {
        'tasks': [
          {'title': '', 'dueDate': null},
        ],
      },
      {
        'tasks': [
          {'title': 'Read', 'dueDate': '2026-02-30'},
        ],
      },
    ]) {
      await expectLater(
        CloudTaskExtractor(call: (_) async => response).extract('Read'),
        throwsFormatException,
      );
    }
  });
  testWidgets(
    'Extraction failure retains notes and retry shows a real empty state',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskUserIdProvider.overrideWith((ref) => 'user'),
            taskExtractorProvider.overrideWithValue(
              CloudTaskExtractor(
                call: (_) async {
                  if (calls++ == 0) throw StateError('network');
                  return {'tasks': []};
                },
              ),
            ),
          ],
          child: const MaterialApp(home: CaptureScreen()),
        ),
      );
      await tester.tap(find.text('Text'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My notes');
      await tester.pump();
      await tester.tap(find.text('Extract tasks'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not extract tasks.'), findsOneWidget);
      expect(find.text('My notes'), findsOneWidget);
      await tester.tap(find.text('Extract tasks'));
      await tester.pumpAndSettle();
      expect(
        find.text('No tasks found. Try a clearer image or different notes.'),
        findsOneWidget,
      );
      expect(calls, 2);
    },
  );
}
