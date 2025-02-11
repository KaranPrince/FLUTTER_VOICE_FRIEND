// File: test/widgets/loading_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/common/loading_widget.dart';

void main() {
  testWidgets('LoadingWidget displays loading animation and text',
      (WidgetTester tester) async {
    // Arrange
    const loadingInfo = 'Loading...';
    const fontSize = 14.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingWidget(
            loadingInfo: loadingInfo,
            fontSize: fontSize,
          ),
        ),
      ),
    );

    // Assert: Check for loading animation
    expect(find.byType(LoadingWidget), findsOneWidget);

    // Assert: Check loading info text
    expect(find.text(loadingInfo), findsOneWidget);
  });
}
