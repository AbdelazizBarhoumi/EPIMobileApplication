// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Refactor: Fixed import to use correct package name
import 'package:flutter_epi_university/main.dart';

void main() {
  testWidgets('App widget smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));

    // Wait for any async operations
    await tester.pumpAndSettle();

    // Verify app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
