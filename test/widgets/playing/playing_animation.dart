// File: test/widgets/playing_animation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/playing/playing_animation.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('PlayingAnimation displays correctly with initial scale',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlayingAnimation(
            width: 200,
          ),
        ),
      ),
    );

    // Assert: Check that the Lottie asset is present
    expect(find.byType(Lottie), findsOneWidget);

    // Optionally check the Transform.scale widget
    final transformFinder = find.byType(Transform);
    expect(transformFinder, findsOneWidget);
    final Transform transform = tester.widget(transformFinder);
    expect(transform.transform.getMaxScaleOnAxis(), equals(1.0));
  });

  testWidgets('PlayingAnimation updates scale when updateScale is called',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlayingAnimation(
            width: 200,
          ),
        ),
      ),
    );

    // Find the state
    final stateFinder = find.byType(PlayingAnimation);
    final state = tester.state<PlayingAnimationState>(stateFinder);

    // Act: Call updateScale
    state.updateScale(1.5);
    await tester.pumpAndSettle();

    // Assert: Verify scale is updated (transform.scale is applied)
    final transformFinderUpdated = find.byType(Transform);
    final Transform transform = tester.widget(transformFinderUpdated);
    // Since we set scale to 1.5
    expect(transform.transform.getMaxScaleOnAxis(), closeTo(1.5, 0.01));
  });
}
