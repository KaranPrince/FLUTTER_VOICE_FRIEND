// File: test/widgets/simple_loading_indicator_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/indicators/simple_loading_indicator.dart';

void main() {
  testWidgets(
      'SimpleLoadingCircle displays CircularProgressIndicator with correct properties',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SimpleLoadingCircle(),
        ),
      ),
    );

    // Assert
    final cpiFinder = find.byType(CircularProgressIndicator);
    expect(cpiFinder, findsOneWidget);

    final CircularProgressIndicator cpi = tester.widget(cpiFinder);
    expect(cpi.valueColor, isA<AlwaysStoppedAnimation<Color>>());
    final AlwaysStoppedAnimation<Color> colorAnimation =
        cpi.valueColor as AlwaysStoppedAnimation<Color>;
    expect(colorAnimation.value, Colors.blue);
    expect(cpi.strokeWidth, equals(8.0));
  });
}
