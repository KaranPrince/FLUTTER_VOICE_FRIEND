import 'package:flutter/material.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:isar/isar.dart';
import 'package:logging/logging.dart'; // Import logging package

final log = Logger('Activities'); // Create a logger

Activity introductionActivity = Activity(
  activityId: ActivityId.introduction,
  name: "Introduction",
  description: 'Introduction activity',
  requiredLevel: 0,
  category: ActivityCategory.dreamActivities,
  displayOrder: 0,
  duration: 5,
  imagePath: 'assets/activities/default_image.webp',
);

// Sync activities with the database
Future<void> syncActivities(Isar isar) async {
  try {
    final existingActivities = await isar.activitys.where().findAll();
    List<Activity> hardcodedActivities = initializeActivities();

    Map<ActivityId, Activity> existingActivitiesMap = {
      for (var activity in existingActivities) activity.activityId: activity
    };

    await isar.writeTxn(() async {
      for (var hardcodedActivity in hardcodedActivities) {
        if (existingActivitiesMap.containsKey(hardcodedActivity.activityId)) {
          final storedActivity =
          existingActivitiesMap[hardcodedActivity.activityId]!;

          if (_isActivityModified(storedActivity, hardcodedActivity)) {
            storedActivity
              ..name = hardcodedActivity.name
              ..description = hardcodedActivity.description
              ..requiredLevel = hardcodedActivity.requiredLevel
              ..category = hardcodedActivity.category
              ..displayOrder = hardcodedActivity.displayOrder
              ..duration = hardcodedActivity.duration
              ..imagePath = hardcodedActivity.imagePath;

            await isar.activitys.put(storedActivity);
            log.info('Updated activity: ${storedActivity.name}'); // Use logger
          }

          existingActivitiesMap.remove(hardcodedActivity.activityId);
        } else {
          await isar.activitys.put(hardcodedActivity);
          log.info('Added new activity: ${hardcodedActivity.name}'); // Use logger
        }
      }

      for (var remainingStoredActivity in existingActivitiesMap.values) {
        await isar.activitys.delete(remainingStoredActivity.id);
        log.info(
            'Removed outdated activity: ${remainingStoredActivity.name}'); // Use logger
      }
    });
  } catch (e, stacktrace) {
    log.severe('Error syncing activities: $e', e, stacktrace); // Log errors
  }
}

bool _isActivityModified(Activity storedActivity, Activity hardcodedActivity) {
  return storedActivity.name != hardcodedActivity.name ||
      storedActivity.description != hardcodedActivity.description ||
      storedActivity.requiredLevel != hardcodedActivity.requiredLevel ||
      storedActivity.category != hardcodedActivity.category ||
      storedActivity.displayOrder != hardcodedActivity.displayOrder ||
      storedActivity.duration != hardcodedActivity.duration ||
      storedActivity.imagePath != hardcodedActivity.imagePath;
}

List<Activity> initializeActivities() {
  return [
    introductionActivity,
    Activity(
      activityId: ActivityId.dreamAnalyst,
      name: 'Whisper the Dream Analyst',
      description: 'A dream analyst to explore your dreams',
      requiredLevel: 1,
      displayOrder: 1,
      category: ActivityCategory.dreamActivities,
      duration: 10,
      imagePath: 'assets/activities/example_image_1.webp',
    ),
  ];
}