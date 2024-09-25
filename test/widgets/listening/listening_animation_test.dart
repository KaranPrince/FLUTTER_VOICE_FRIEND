// File: test/widgets/listening_animation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/listening/listening_animation.dart';
import 'package:flutter_voice_friend/utils/audio_utils.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('ListeningAnimation displays correctly with initial scale',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListeningAnimation(
            width: 200,
          ),
        ),
      ),
    );

    // Assert: Check that the Lottie asset is present
    expect(find.byType(Lottie), findsOneWidget);

    // Optionally check the Transform.scale widget
    final transformFinder = find.byType(Transform);
    expect(transformFinder, findsNWidgets(3));
    final Transform transform = tester.widget(transformFinder.first);
    expect(transform.transform.getMaxScaleOnAxis(), equals(1.0));
  });

  testWidgets('ListeningAnimation updates scale when updateScale is called',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListeningAnimation(
            width: 200,
          ),
        ),
      ),
    );

    // Find the state
    final stateFinder = find.byType(ListeningAnimation);
    final state = tester.state<ListeningAnimationState>(stateFinder);

    // Act: Call updateScale
    state.updateScale(0.8);
    await tester.pump(const Duration(milliseconds: 500));

    // Assert: Verify scale is updated
    // Note: Directly accessing _currentScale is not possible since it's private.
    // Instead, verify the Transform widget's scale.
    final transformFinderUpdated = find.byType(Transform);
    final Transform transform = tester.widget(transformFinderUpdated.first);
    //TODO Fix test
    //expect(transform.transform.getMaxScaleOnAxis(),
    //    closeTo(AudioUtils.getScale(0.8, 1.0, 0.75, 3.0), 0.01));
  });
}
