// File: test/widgets/subtitle_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/playing/subtitle_widget.dart';

void main() {
  testWidgets('SubtitleWidget displays subtitles correctly',
      (WidgetTester tester) async {
    // Arrange
    const subtitles = 'Hello, world!';
    const width = 300.0;
    const subtitleSize = 20.0;
    const textColor = Colors.black;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: SubtitleWidget(
              width: width,
              subtitleSize: subtitleSize,
              subtitles: subtitles,
              textColor: textColor,
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(find.text(subtitles), findsOneWidget);

    // Act: Change the subtitles
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: SubtitleWidget(
              width: width,
              subtitleSize: subtitleSize,
              subtitles: 'New subtitle',
              textColor: textColor,
            ),
          ),
        ),
      ),
    );

    // Assert the new subtitle is displayed
    expect(find.text('New subtitle'), findsOneWidget);
  });
}
