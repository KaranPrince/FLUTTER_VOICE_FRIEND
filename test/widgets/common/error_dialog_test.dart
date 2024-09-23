// File: test/widgets/error_dialog_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/common/error_dialog.dart';

void main() {
  testWidgets('showErrorDialog displays error message and OK button',
      (WidgetTester tester) async {
    // Arrange
    const errorMessage = 'An error occurred!';
    bool dialogClosed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await showErrorDialog(context, errorMessage);
              dialogClosed = true;
            },
            child: const Text('Show Error'),
          ),
        ),
      ),
    );

    // Act: Tap the button to show dialog
    await tester.tap(find.text('Show Error'));
    await tester.pumpAndSettle();

    // Assert: Check dialog elements
    expect(find.text('Ouch !'), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    // Act: Tap OK button
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Assert: Dialog is closed
    expect(dialogClosed, isTrue);
  });

  testWidgets('showErrorDialog does not show OK button when showOk is false',
      (WidgetTester tester) async {
    // Arrange
    const errorMessage = 'Another error!';
    bool dialogClosed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await showErrorDialog(context, errorMessage, showOk: false);
              dialogClosed = true;
            },
            child: const Text('Show Error'),
          ),
        ),
      ),
    );

    // Act: Tap the button to show dialog
    await tester.tap(find.text('Show Error'));
    await tester.pumpAndSettle();

    // Assert: Check dialog elements
    expect(find.text('Ouch !'), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text('OK'), findsNothing);

    // Since there is no button to dismiss, the dialog remains
    expect(dialogClosed, isFalse);
  });
}
