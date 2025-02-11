// File: test/widgets/dialog_helper_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/dialog_helper.dart';

void main() {
  testWidgets('showIntroductionActivityCompletionDialog displays correctly',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await showIntroductionActivityCompletionDialog(context);
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );

    // Act: Tap the button to show dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Assert: Check dialog elements
    expect(find.text('Activity Completed'), findsOneWidget);
    expect(
        find.text('Click on Continue to go to the main menu'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Act: Tap 'Continue' button
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Since the dialog returns false, we can capture the result if needed
  });

  testWidgets(
      'showActivityCompletionDialog displays correctly and returns correct value',
      (WidgetTester tester) async {
    // Arrange
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showActivityCompletionDialog(context);
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );

    // Act: Tap the button to show dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Assert: Check dialog elements
    expect(find.text('Activity Completed'), findsOneWidget);
    expect(
        find.text(
            'Would you like to return to the main menu or restart the activity?'),
        findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Main Menu'), findsOneWidget);

    // Act: Tap 'Main Menu' button
    await tester.tap(find.text('Main Menu'));
    await tester.pumpAndSettle();

    // Assert: result should be true
    expect(result, isTrue);
  });
}
