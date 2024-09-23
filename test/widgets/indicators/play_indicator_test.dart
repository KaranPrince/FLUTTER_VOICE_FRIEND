// File: test/widgets/play_indicator_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/indicators/play_indicator.dart';
import 'package:flutter_voice_friend/services/animation_controller_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'play_indicator_test.mocks.dart';

@GenerateMocks([AnimationControllerService])
void main() {
  late MockAnimationControllerService mockAnimationControllerService;

  setUp(() {
    mockAnimationControllerService = MockAnimationControllerService();

    // Mock the pulseAnimation and animation
    when(mockAnimationControllerService.pulseAnimation)
        .thenReturn(const AlwaysStoppedAnimation(1.0));
    when(mockAnimationControllerService.animation)
        .thenReturn(const AlwaysStoppedAnimation(1.0));
    when(mockAnimationControllerService.animationController)
        .thenReturn(FakeAnimationController());
    when(mockAnimationControllerService.buttonAnimationController)
        .thenReturn(FakeAnimationController());
    when(mockAnimationControllerService.listeningAnimationController)
        .thenReturn(FakeAnimationController());
  });

  testWidgets('PlayIndicatorWidget displays play button and title',
      (WidgetTester tester) async {
    // Arrange
    const title = 'Play';
    bool onPressCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayIndicatorWidget(
            animationControllerService: mockAnimationControllerService,
            isListening: false,
            title: title,
            textColor: Colors.black,
            onPress: () {
              onPressCalled = true;
            },
          ),
        ),
      ),
    );

    // Assert: Play button is present
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Assert: Title is present
    expect(find.text(title), findsOneWidget);

    // Act: Tap the play button
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();

    // Advance the clock by 500 milliseconds to allow the Timer to complete
    await tester.pump(const Duration(milliseconds: 500));

    // Assert callback
    expect(onPressCalled, isTrue);
  });
}

// A fake AnimationController to satisfy the type
class FakeAnimationController extends AnimationController {
  FakeAnimationController() : super(vsync: const TestVSync());

  @override
  TickerFuture forward({double? from}) {
    return TickerFuture.complete();
  }

  @override
  TickerFuture reverse({double? from}) {
    return TickerFuture.complete();
  }
}
