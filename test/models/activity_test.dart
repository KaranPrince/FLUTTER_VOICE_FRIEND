import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/models/activity.dart';

void main() {
  group('Activity Model Tests', () {
    group('Creation Tests', () {
      test('Should create an Activity instance with all required values', () {
        final activity = Activity(
          id: 1234,
          activityId: ActivityId.introduction,
          name: 'Introduction',
          description: 'Introduction activity',
          requiredLevel: 3,
          displayOrder: 10,
          category: ActivityCategory.dreamActivities,
          duration: 5,
          imagePath: 'assets/activities/default_image.webp',
          isCompleted: true,
        );

        //expect(activity.id, 1234);
        expect(activity.activityId, ActivityId.introduction);
        expect(activity.name, 'Introduction');
        expect(activity.description, 'Introduction activity');
        expect(activity.requiredLevel, 3);
        expect(activity.displayOrder, 10);
        expect(activity.category, ActivityCategory.dreamActivities);
        expect(activity.duration, 5);
        expect(activity.imagePath, 'assets/activities/default_image.webp');
        expect(activity.isCompleted, true);
        expect(activity.lastCompleted, null);
      });

      test('Should create an Activity instance with default optional values',
          () {
        final activity = Activity(
          activityId: ActivityId.dreamAnalyst,
          name: 'Dream Analyst',
          description: 'Analyze your dreams',
          requiredLevel: 1,
          displayOrder: 1,
          category: ActivityCategory.dreamActivities,
          duration: 15,
        );

        expect(activity.activityId, ActivityId.dreamAnalyst);
        expect(activity.name, 'Dream Analyst');
        expect(activity.description, 'Analyze your dreams');
        expect(activity.requiredLevel, 1);
        expect(activity.displayOrder, 1);
        expect(activity.category, ActivityCategory.dreamActivities);
        expect(activity.duration, 15);
        expect(activity.imagePath, '');
        expect(activity.isCompleted, false);
        expect(activity.lastCompleted, null);
      });
    });

    group('Property Update Tests', () {
      test('Should update isCompleted and lastCompleted correctly', () {
        final activity = Activity(
          activityId: ActivityId.introduction,
          name: 'Introduction',
          description: 'Introduction activity',
          requiredLevel: 0,
          displayOrder: 0,
          category: ActivityCategory.dreamActivities,
          duration: 5,
        );

        expect(activity.isCompleted, false);
        expect(activity.lastCompleted, null);

        activity.isCompleted = true;
        final now = DateTime.now();
        activity.lastCompleted = now;

        expect(activity.isCompleted, true);
        expect(activity.lastCompleted, isNotNull);
        expect(activity.lastCompleted, closeToDateTime(now));
      });

      test('Should allow updating optional fields', () {
        final activity = Activity(
          activityId: ActivityId.introduction,
          name: 'Introduction',
          description: 'Introduction activity',
          requiredLevel: 0,
          displayOrder: 0,
          category: ActivityCategory.dreamActivities,
          duration: 5,
        );

        activity.description = 'Updated description';
        activity.name = 'Updated Name';
        activity.imagePath = 'assets/activities/updated_image.webp';

        expect(activity.description, 'Updated description');
        expect(activity.name, 'Updated Name');
        expect(activity.imagePath, 'assets/activities/updated_image.webp');
      });
    });

    group('Enum Tests', () {
      test('Should accept all valid ActivityId enum values', () {
        for (var id in ActivityId.values) {
          final activity = Activity(
            activityId: id,
            name: 'Test Activity',
            description: 'Description',
            requiredLevel: 0,
            displayOrder: 0,
            category: ActivityCategory.dreamActivities,
            duration: 10,
          );
          expect(activity.activityId, id);
        }
      });

      test('Should accept all valid ActivityCategory enum values', () {
        for (var category in ActivityCategory.values) {
          final activity = Activity(
            activityId: ActivityId.introduction,
            name: 'Test Activity',
            description: 'Description',
            requiredLevel: 0,
            displayOrder: 0,
            category: category,
            duration: 10,
          );
          expect(activity.category, category);
        }
      });
    });

    group('Edge Case Tests', () {
      test('Should handle zero duration', () {
        final activity = Activity(
          activityId: ActivityId.introduction,
          name: 'Zero Duration Activity',
          description: 'Activity with zero duration',
          requiredLevel: 0,
          displayOrder: 0,
          category: ActivityCategory.dreamActivities,
          duration: 0,
        );

        expect(activity.duration, 0);
      });

      test('Should handle negative duration', () {
        final activity = Activity(
          activityId: ActivityId.introduction,
          name: 'Negative Duration Activity',
          description: 'Activity with negative duration',
          requiredLevel: 0,
          displayOrder: 0,
          category: ActivityCategory.dreamActivities,
          duration: -10,
        );

        expect(activity.duration, -10);
      });

      test('Should handle very long strings', () {
        final longString = 'a' * 1000;
        final activity = Activity(
          activityId: ActivityId.introduction,
          name: longString,
          description: longString,
          requiredLevel: 0,
          displayOrder: 0,
          category: ActivityCategory.dreamActivities,
          duration: 10,
        );

        expect(activity.name, longString);
        expect(activity.description, longString);
      });

      test('Should handle null lastCompleted', () {
        final activity = Activity(
          activityId: ActivityId.introduction,
          name: 'Test Activity',
          description: 'Description',
          requiredLevel: 0,
          displayOrder: 0,
          category: ActivityCategory.dreamActivities,
          duration: 10,
          lastCompleted: null,
        );

        expect(activity.lastCompleted, null);
      });
    });
  });
}

/// Helper matcher to compare DateTime with a tolerance
Matcher closeToDateTime(DateTime expected,
    {Duration tolerance = const Duration(seconds: 1)}) {
  return predicate<DateTime>((actual) {
    return (actual.difference(expected).abs() <= tolerance);
  }, 'is close to $expected within $tolerance');
}
