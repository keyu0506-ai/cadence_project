// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence_project/features/auth/providers/auth_providers.dart';

import 'package:cadence_project/main.dart';

void main() {
  testWidgets('Welcome screen shows the Cadence introduction', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cadence'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Snap a note → instant calendar'), findsOneWidget);
  });
}
