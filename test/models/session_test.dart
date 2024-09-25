import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/models/session.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:isar/isar.dart';

void main() {
  group('Session Model Tests', () {
    group('Creation Tests', () {
      test('Should create a Session instance with all provided values', () {
        final now = DateTime.now();
        final session = Session(
          date: now,
          conversationLog: 'Sample conversation',
          sessionSummary: 'Sample summary',
          duration: 10,
        );

        expect(session.date, now);
        expect(session.conversationLog, 'Sample conversation');
        expect(session.sessionSummary, 'Sample summary');
        expect(session.duration, 10);
        expect(session.activity.value, null);
      });

      test('Should create a Session instance with default optional values', () {
        final now = DateTime.now();
        final session = Session(
          date: now,
        );

        expect(session.date, now);
        expect(session.conversationLog, '');
        expect(session.sessionSummary, '');
        expect(session.duration, 0);
        expect(session.activity.value, null);
      });
    });

    group('Property Update Tests', () {
      test('Should update conversationLog and sessionSummary correctly', () {
        final session = Session(
          date: DateTime.now(),
        );

        session.conversationLog = 'Updated conversation log';
        session.sessionSummary = 'Updated session summary';
        session.duration = 20;

        expect(session.conversationLog, 'Updated conversation log');
        expect(session.sessionSummary, 'Updated session summary');
        expect(session.duration, 20);
      });

      test('Should allow updating the date', () {
        final session = Session(
          date: DateTime(2023, 1, 1),
        );

        final newDate = DateTime(2024, 1, 1);
        session.date = newDate;

        expect(session.date, newDate);
      });
    });

    group('Relation Tests', () {
      test('Should initially have null activity link', () {
        final session = Session(
          date: DateTime.now(),
        );

        expect(session.activity.value, null);
      });
    });

    group('Enum and Type Tests', () {
      test('Should have correct types for all properties', () {
        final now = DateTime.now();
        final session = Session(
          date: now,
          conversationLog: 'Conversation',
          sessionSummary: 'Summary',
          duration: 30,
        );

        expect(session.date, isA<DateTime>());
        expect(session.conversationLog, isA<String>());
        expect(session.sessionSummary, isA<String>());
        expect(session.duration, isA<int>());
        expect(session.activity, isA<IsarLink<Activity>>());
      });
    });

    group('Edge Case Tests', () {
      test('Should handle zero duration', () {
        final session = Session(
          date: DateTime.now(),
          duration: 0,
        );

        expect(session.duration, 0);
      });

      test('Should handle negative duration', () {
        final session = Session(
          date: DateTime.now(),
          duration: -15,
        );

        expect(session.duration, -15);
      });

      test('Should handle very long conversationLog and sessionSummary', () {
        final longString = 'a' * 1000;
        final session = Session(
          date: DateTime.now(),
          conversationLog: longString,
          sessionSummary: longString,
        );

        expect(session.conversationLog, longString);
        expect(session.sessionSummary, longString);
      });

      test('Should handle null activity link', () {
        final session = Session(
          date: DateTime.now(),
        );

        expect(session.activity.value, null);
      });
    });
  });
}
