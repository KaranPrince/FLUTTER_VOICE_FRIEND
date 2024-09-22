import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:flutter_voice_friend/models/session.dart';
import 'package:flutter_voice_friend/services/session_service.dart';
import 'package:isar/isar.dart';
import 'package:mockito/mockito.dart';

// Mock class for IsarCollection<Session>
class MockIsarCollectionSession extends Mock
    implements IsarCollection<Session> {
  @override
  Future<Session?> get(Id id) {
    // Simulate behavior for retrieving a session
    return Future.value(null); // Return null or a mocked session as needed
  }
}

// Mock class for IsarCollection<Activity>
class MockIsarCollectionActivity extends Mock
    implements IsarCollection<Activity> {
  @override
  Future<Activity?> get(Id id) {
    // Simulate behavior for retrieving an activity
    return Future.value(null); // Return null to simulate "not found"
  }
}

// Custom MockIsar class
class MockIsar extends Mock implements Isar {
  final IsarCollection<Session> mockSessionCollection;
  final IsarCollection<Activity> mockActivityCollection;

  MockIsar({
    required this.mockSessionCollection,
    required this.mockActivityCollection,
  });

  @override
  IsarCollection<T> collection<T>() {
    if (T == Session) {
      return mockSessionCollection as IsarCollection<T>;
    } else if (T == Activity) {
      return mockActivityCollection as IsarCollection<T>;
    } else {
      throw UnimplementedError('collection<$T>() not implemented in MockIsar');
    }
  }
}

void main() {
  group('SessionService Tests', () {
    late SessionService sessionService;
    late MockIsar mockIsar;
    late MockIsarCollectionSession mockSessionCollection;
    late MockIsarCollectionActivity mockActivityCollection;

    setUp(() {
      mockSessionCollection = MockIsarCollectionSession();
      mockActivityCollection = MockIsarCollectionActivity();

      mockIsar = MockIsar(
        mockSessionCollection: mockSessionCollection,
        mockActivityCollection: mockActivityCollection,
      );

      sessionService = SessionService(isar: mockIsar);
    });

    test('Should throw exception when activity not found', () async {
      final activity = Activity(
        activityId: ActivityId.introduction,
        name: 'Introduction',
        description: 'Intro activity',
        requiredLevel: 0,
        displayOrder: 0,
        category: ActivityCategory.dreamActivities,
        duration: 5,
      );

      // Expect that an exception is thrown when the activity is not found
      expect(
        () => sessionService.saveSession(
          'conversation',
          'summary',
          DateTime.now(),
          activity,
        ),
        throwsException,
      );
    });

    // Add more tests covering:
    // - Successful session saving
    // - Updating activity's isCompleted and lastCompleted
    // - Corner cases like invalid data
  });
}
