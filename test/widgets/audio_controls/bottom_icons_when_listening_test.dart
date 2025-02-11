// File: test/widgets/bottom_icons_when_listening_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/audio_controls/bottom_icons_when_listening.dart';
import 'package:flutter_voice_friend/services/animation_controller_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'bottom_icons_when_listening_test.mocks.dart';

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

@GenerateMocks([AnimationControllerService])
void main() {
  late MockAnimationControllerService mockAnimationControllerService;

  setUp(() {
    mockAnimationControllerService = MockAnimationControllerService();
    when(mockAnimationControllerService.buttonAnimation)
        .thenReturn(const AlwaysStoppedAnimation(1.0));
    when(mockAnimationControllerService.pulseAnimation)
        .thenReturn(const AlwaysStoppedAnimation(1.0));
    when(mockAnimationControllerService.animation)
        .thenReturn(const AlwaysStoppedAnimation(1.0));
    when(mockAnimationControllerService.buttonAnimationController)
        .thenReturn(FakeAnimationController());
    when(mockAnimationControllerService.listeningAnimationController)
        .thenReturn(FakeAnimationController());
  });

  testWidgets(
      'BottomIconsWhenListening shows cancel and stop when isListening is true',
      (WidgetTester tester) async {
    // Arrange
    bool onCancelCalled = false;
    bool onStopCalled = false;
    bool onToggleCalled = false;
    bool onRestartCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomIconsWhenListening(
            isListening: true,
            animationControllerService: mockAnimationControllerService,
            onCancelListening: () {
              onCancelCalled = true;
            },
            onStopListening: () {
              onStopCalled = true;
            },
            onToggleListening: (bool val) {
              onToggleCalled = true;
            },
            onRestartListening: () {
              onRestartCalled = true;
            },
            firstMessage: false,
          ),
        ),
      ),
    );

    // Assert: Cancel and Stop icons are present
    expect(find.byIcon(Icons.cancel), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byIcon(Icons.replay), findsNothing);

    // Act: Tap Cancel
    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pumpAndSettle();

    // Assert
    expect(onCancelCalled, isTrue);

    // Act: Tap Stop
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pumpAndSettle();

    // Assert
    expect(onStopCalled, isTrue);
  });

  testWidgets('BottomIconsWhenListening shows mic when isListening is false',
      (WidgetTester tester) async {
    // Arrange
    bool onToggleCalled = false;

    // Ensure that calling forward returns a valid TickerFuture

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomIconsWhenListening(
            isListening: false,
            animationControllerService: mockAnimationControllerService,
            onCancelListening: () {},
            onStopListening: () {},
            onToggleListening: (bool val) {
              onToggleCalled = true;
            },
            onRestartListening: () {},
            firstMessage: true,
          ),
        ),
      ),
    );

    // Assert: Mic icon is present
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Act: Tap Mic
    //await
    await tester.tap(find.byIcon(Icons.mic));
    //await tester.pumpAndSettle();

    // Assert
    expect(onToggleCalled, isTrue);
  });
}
