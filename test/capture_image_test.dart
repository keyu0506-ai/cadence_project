import 'package:cadence_project/features/capture/data/task_extractor.dart';
import 'package:cadence_project/features/capture/data/demo_task_extractor.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadence_project/features/capture/data/local_image_picker.dart';
import 'package:cadence_project/features/capture/presentation/screens/capture_screen.dart';
import 'package:cadence_project/features/tasks/tasks_provider.dart';

final png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

class ControlledImagePicker extends LocalImagePicker {
  int calls = 0;
  NoteImage? next;
  Exception? error;
  Completer<NoteImage?>? pending;
  @override
  Future<NoteImage?> pick() async {
    calls++;
    if (error != null) throw error!;
    if (pending != null) return pending!.future;
    return next;
  }
}

void main() {
  testWidgets(
    'Picker validates and decodes local PNG; handles cancel, corrupt and large files',
    (tester) async {
      await tester.runAsync(() async {
        final picker = LocalImagePicker(
          selectFile: () async =>
              XFile.fromData(png, name: 'notes.png', path: 'notes.png'),
        );
        final selected = await picker.pick();
        expect(selected!.name, 'notes.png');
        expect(selected.bytes, png);
        expect(
          await LocalImagePicker(selectFile: () async => null).pick(),
          isNull,
        );
        for (final file in [
          XFile.fromData(png, name: 'notes.pdf', path: 'notes.pdf'),
          XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            name: 'broken.png',
            path: 'broken.png',
          ),
          XFile.fromData(
            Uint8List(LocalImagePicker.maxBytes + 1),
            name: 'large.png',
            path: 'large.png',
          ),
        ]) {
          await expectLater(
            LocalImagePicker(selectFile: () async => file).pick(),
            throwsFormatException,
          );
        }
      });
    },
  );

  testWidgets(
    'Photo selection gates extraction and preserves image across mode changes and cancellation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final picker = ControlledImagePicker();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskExtractorProvider.overrideWithValue(DemoTaskExtractor()),
            localImagePickerProvider.overrideWithValue(picker),
            taskUserIdProvider.overrideWith((ref) => 'alice'),
          ],
          child: const MaterialApp(home: CaptureScreen()),
        ),
      );
      FilledButton extractButton() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Extract tasks'),
      );
      expect(extractButton().onPressed, isNull);
      await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
      await tester.pumpAndSettle();
      expect(picker.calls, 1);
      final uploadArea = find.byKey(const ValueKey('photo-upload-area'));
      await tester.tapAt(tester.getTopLeft(uploadArea) + const Offset(12, 12));
      await tester.pumpAndSettle();
      expect(picker.calls, 2);
      await tester.tap(find.text('Upload image'));
      await tester.pumpAndSettle();
      expect(picker.calls, 3);
      expect(extractButton().onPressed, isNull);

      picker.pending = Completer<NoteImage?>();
      await tester.tap(find.text('Upload image'));
      await tester.pump();
      expect(find.text('Loading image…'), findsOneWidget);
      expect(extractButton().onPressed, isNull);
      picker.pending!.complete(NoteImage(name: 'syllabus.png', bytes: png));
      picker.pending = null;
      await tester.pumpAndSettle();
      expect(find.text('syllabus.png'), findsOneWidget);
      expect(extractButton().onPressed, isNotNull);
      await tester.tap(find.text('Text'));
      await tester.pumpAndSettle();
      expect(extractButton().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'My notes');
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();
      expect(find.text('syllabus.png'), findsOneWidget);
      await tester.tap(find.byTooltip('Replace image'));
      await tester.pumpAndSettle();
      expect(find.text('syllabus.png'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove image'));
      await tester.pumpAndSettle();
      expect(extractButton().onPressed, isNull);
      picker.error = const FormatException('Choose a JPG or PNG image.');
      await tester.tap(find.text('Upload image'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a JPG or PNG image.'), findsOneWidget);
      expect(extractButton().onPressed, isNull);
      picker.error = null;
      picker.next = NoteImage(name: 'replacement.png', bytes: png);
      await tester.tap(find.text('Upload image'));
      await tester.pumpAndSettle();
      expect(find.text('replacement.png'), findsOneWidget);
      await tester.tap(find.text('Extract tasks'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(
        find.text('AI-extracted tasks · Check details before saving'),
        findsOneWidget,
      );
      expect(find.text('Add 3 to my schedule'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
