// File: test/widgets/listening_message_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/listening/listening_message.dart';

void main() {
  testWidgets(
      'ListeningMessage displays "Tap microphone to talk" when conditions met',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListeningMessage(
            listeningMode: true,
            firstMessage: false,
            isListening: false,
            transcription: '',
            textColor: Colors.black,
            audioLevel: 1.0,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Tap microphone to talk'), findsOneWidget);
  });

  testWidgets('ListeningMessage displays "Start talking" when conditions met',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListeningMessage(
            listeningMode: true,
            firstMessage: false,
            isListening: true,
            transcription: '',
            textColor: Colors.black,
            audioLevel: 0.0,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Start talking'), findsOneWidget);
  });

  testWidgets('ListeningMessage displays "Press ⬜ to send" when conditions met',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListeningMessage(
            listeningMode: true,
            firstMessage: false,
            isListening: true,
            transcription: 'Hello',
            textColor: Colors.black,
            audioLevel: 0.0,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Press ⬜ to send'), findsOneWidget);
  });

  testWidgets('ListeningMessage displays nothing when no condition met',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListeningMessage(
            listeningMode: false,
            firstMessage: true,
            isListening: false,
            transcription: '',
            textColor: Colors.black,
            audioLevel: 1.0,
          ),
        ),
      ),
    );

    // Assert
    expect(find.byType(Text), findsNothing);
  });
}
