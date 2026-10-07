import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadence_project/features/capture/presentation/widgets/task_draft_card.dart';
import 'package:cadence_project/features/tasks/task.dart';

void main() {
  testWidgets(
    'Compact card supports a long subject and editing on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var draft = const TaskDraft(
        id: '1',
        title: 'Read Ch. 9 & annotate (pp. 142–161)',
        subject:
            'Advanced biological sciences and experimental laboratory methods',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) => TaskDraftCard(
                  draft: draft,
                  selected: false,
                  onSelected: (_) {},
                  onChanged: (value) => setState(() => draft = value),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Deadline required'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Edit task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'Chemistry');
      await tester.pump();
      expect(draft.subject, 'Chemistry');
      expect(draft.title, 'Read Ch. 9 & annotate (pp. 142–161)');
      await tester.tap(find.byTooltip('Done editing task'));
      await tester.pumpAndSettle();
      expect(find.text('Chemistry'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
