import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/models/session.dart';

void main() {
  group('Session Model Tests', () {
    test('Should create a Session instance with correct values', () {
      final session = Session(
        date: DateTime.now(),
        conversationLog: 'Sample conversation',
        sessionSummary: 'Sample summary',
        duration: 10,
      );

      expect(session.date, isA<DateTime>());
      expect(session.conversationLog, 'Sample conversation');
      expect(session.sessionSummary, 'Sample summary');
      expect(session.duration, 10);
    });

    test('Should have null activity link initially', () {
      final session = Session(
        date: DateTime.now(),
        conversationLog: '',
        sessionSummary: '',
        duration: 0,
      );

      expect(session.activity.value, null);
    });
  });
}
