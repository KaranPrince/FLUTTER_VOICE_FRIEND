import 'package:flutter/material.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:isar/isar.dart';

Activity introductionActivity = Activity(
  activityId: ActivityId.introduction, // Use the enum for activityId
  name: "Introduction", // Direct name assignment
  description: 'Introduction activity', // Description
  requiredLevel: 0, // Required level
  category: ActivityCategory.dreamActivities, // Category for the activity
  displayOrder: 0, // Display order
  duration: 5, // Set a duration for the activity (e.g., 5 minutes)
  imagePath:
      'assets/activities/default_image.webp', // Direct image path assignment
);

// Sync activities with the database
Future<void> syncActivities(Isar isar) async {
  // Load existing activities from Isar
  final existingActivities = await isar.activitys.where().findAll();

  // Hardcoded list of activities
  List<Activity> hardcodedActivities = initializeActivities();

  // Convert existing activities into a map for easy comparison by activityId
  Map<ActivityId, Activity> existingActivitiesMap = {
    for (var activity in existingActivities) activity.activityId: activity
  };

  // Start an Isar transaction to update the database
  await isar.writeTxn(() async {
    for (var hardcodedActivity in hardcodedActivities) {
      if (existingActivitiesMap.containsKey(hardcodedActivity.activityId)) {
        final storedActivity =
            existingActivitiesMap[hardcodedActivity.activityId]!;

        // Check if the activity has changed, and update it if necessary
        if (_isActivityModified(storedActivity, hardcodedActivity)) {
          storedActivity
            ..name = hardcodedActivity.name
            ..description = hardcodedActivity.description
            ..requiredLevel = hardcodedActivity.requiredLevel
            ..category = hardcodedActivity.category
            ..displayOrder = hardcodedActivity.displayOrder
            ..duration = hardcodedActivity.duration
            ..imagePath = hardcodedActivity.imagePath;

          await isar.activitys.put(storedActivity); // Update existing activity
          debugPrint('Updated activity: ${storedActivity.name}');
        }

        // Remove the existing activity from the map, so it's not reprocessed
        existingActivitiesMap.remove(hardcodedActivity.activityId);
      } else {
        // Add new activity to the database
        await isar.activitys.put(hardcodedActivity);
        debugPrint('Added new activity: ${hardcodedActivity.name}');
      }
    }

    // Optionally: Remove old activities that are no longer in the hardcoded list
    for (var remainingStoredActivity in existingActivitiesMap.values) {
      await isar.activitys.delete(remainingStoredActivity.id);
      debugPrint('Removed outdated activity: ${remainingStoredActivity.name}');
    }
  });
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

// Function to initialize activities with proper categories, levels, and orders
List<Activity> initializeActivities() {
  return [
    // Kids Activities
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
