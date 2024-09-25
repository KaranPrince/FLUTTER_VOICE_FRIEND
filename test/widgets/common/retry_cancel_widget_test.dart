// File: test/widgets/retry_cancel_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/common/retry_cancel_widget.dart';

void main() {
  testWidgets('RetryCancelWidget displays error messages and buttons',
      (WidgetTester tester) async {
    // Arrange
    bool onRetryCalled = false;
    bool onCancelCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RetryCancelWidget(
            onRetry: () {
              onRetryCalled = true;
            },
            onCancel: () {
              onCancelCalled = true;
            },
          ),
        ),
      ),
    );

    // Assert: Check error messages
    expect(find.textContaining('Whisper had a little hiccup'), findsOneWidget);
    expect(find.textContaining('I can retry sending your command'),
        findsOneWidget);

    // Assert: Buttons are present
    expect(find.text('Retry 🔄'), findsOneWidget);
    expect(find.text('Cancel ❌'), findsOneWidget);

    // Act: Tap Retry
    await tester.tap(find.text('Retry 🔄'));
    await tester.pumpAndSettle();

    // Assert
    expect(onRetryCalled, isTrue);
    expect(onCancelCalled, isFalse);

    // Reset
    onRetryCalled = false;

    // Act: Tap Cancel
    await tester.tap(find.text('Cancel ❌'));
    await tester.pumpAndSettle();

    // Assert
    expect(onCancelCalled, isTrue);
    expect(onRetryCalled, isFalse);
  });
}
