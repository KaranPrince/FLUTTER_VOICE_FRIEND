import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/utils/text_utils.dart';

void main() {
  group('TextUtils Tests', () {
    test('Should segment text by sentence correctly', () {
      const text = 'Hello world! How are you today? I am fine.';
      final result = segmentTextBySentence(text);

      expect(
          result['completeSentences'], ['Hello world!', 'How are you today?']);
      expect(result['remainingText'], 'I am fine.');
    });

    test('Should handle empty string', () {
      final result = segmentTextBySentence('');

      expect(result['completeSentences'], []);
      expect(result['remainingText'], '');
    });

    test('Should format time since last completed correctly', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(Duration(hours: 1));
      final result = timeSinceLastCompleted(oneHourAgo);

      expect(result, '60 mins ago');
    });

    // Add more tests for different durations
  });
}
