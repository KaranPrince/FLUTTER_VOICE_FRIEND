// File: test/widgets/bottom_icons_when_playing_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/audio_controls/bottom_icons_when_playing.dart';

void main() {
  testWidgets(
      'BottomIconsWhenPlaying shows pause icon when playing and not paused',
      (WidgetTester tester) async {
    // Arrange
    bool onPauseCalled = false;
    bool onStopCalled = false;
    bool onRepeatCalled = false;
    bool onNextCalled = false;
    bool onResumeCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomIconsWhenPlaying(
            isPlaying: true,
            isPaused: false,
            remainingLLMResponse: false,
            onPause: () {
              onPauseCalled = true;
            },
            onStop: () {
              onStopCalled = true;
            },
            onRepeat: () {
              onRepeatCalled = true;
            },
            onNext: () {
              onNextCalled = true;
            },
            onResume: () {
              onResumeCalled = true;
            },
            lastAudioToPlay: false,
          ),
        ),
      ),
    );

    // Assert: Pause icon is present
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // Act: Tap Pause
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pumpAndSettle();

    // Assert callback
    expect(onPauseCalled, isTrue);
  });

  testWidgets('BottomIconsWhenPlaying shows stop, repeat, next when paused',
      (WidgetTester tester) async {
    // Arrange
    bool onPauseCalled = false;
    bool onStopCalled = false;
    bool onRepeatCalled = false;
    bool onNextCalled = false;
    bool onResumeCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomIconsWhenPlaying(
            isPlaying: false,
            isPaused: true,
            remainingLLMResponse: false,
            onPause: () {
              onPauseCalled = true;
            },
            onStop: () {
              onStopCalled = true;
            },
            onRepeat: () {
              onRepeatCalled = true;
            },
            onNext: () {
              onNextCalled = true;
            },
            onResume: () {
              onResumeCalled = true;
            },
            lastAudioToPlay: false,
          ),
        ),
      ),
    );

    // Assert: Stop, Repeat, Next icons are present
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);

    // Act: Tap Stop
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pumpAndSettle();

    // Assert callback
    expect(onStopCalled, isTrue);

    // Act: Tap Repeat
    await tester.tap(find.byIcon(Icons.repeat));
    await tester.pumpAndSettle();

    // Assert callback
    expect(onRepeatCalled, isTrue);

    // Act: Tap Next
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();

    // Assert callback
    expect(onNextCalled, isTrue);
  });

  testWidgets('BottomIconsWhenPlaying shows End when lastAudioToPlay is true',
      (WidgetTester tester) async {
    // Arrange
    bool onNextCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BottomIconsWhenPlaying(
            isPlaying: false,
            isPaused: true,
            remainingLLMResponse: false,
            onPause: () {},
            onStop: () {},
            onRepeat: () {},
            onNext: () {
              onNextCalled = true;
            },
            onResume: () {},
            lastAudioToPlay: true,
          ),
        ),
      ),
    );

    // Assert: End text is present
    expect(find.text('End'), findsOneWidget);

    // Act: Tap Next (End)
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();

    // Assert callback
    expect(onNextCalled, isTrue);
  });
}
