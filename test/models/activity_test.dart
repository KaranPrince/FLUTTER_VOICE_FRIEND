import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/models/activity.dart';

void main() {
  group('Activity Model Tests', () {
    test('Should create an Activity instance with correct values', () {
      final activity = Activity(
        activityId: ActivityId.introduction,
        name: 'Introduction',
        description: 'Introduction activity',
        requiredLevel: 0,
        displayOrder: 0,
        category: ActivityCategory.dreamActivities,
        duration: 5,
        imagePath: 'assets/activities/default_image.webp',
      );

      expect(activity.activityId, ActivityId.introduction);
      expect(activity.name, 'Introduction');
      expect(activity.description, 'Introduction activity');
      expect(activity.requiredLevel, 0);
      expect(activity.displayOrder, 0);
      expect(activity.category, ActivityCategory.dreamActivities);
      expect(activity.duration, 5);
      expect(activity.imagePath, 'assets/activities/default_image.webp');
      expect(activity.isCompleted, false);
      expect(activity.lastCompleted, null);
    });

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

      activity.isCompleted = true;
      activity.lastCompleted = DateTime.now();

      expect(activity.isCompleted, true);
      expect(activity.lastCompleted, isNotNull);
    });
  });
}
