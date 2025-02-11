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
  imagePath: 'assets/activities/default_image.webp', // Direct image path assignment
);

// ✅ NEW ACTIVITY: Define Your Custom Activity
Activity myNewActivity = Activity(
  activityId: ActivityId.myNewActivity, // New activity ID
  name: "My New Activity", // Name for display
  description: 'A new interactive activity to guide the user', // Brief description
  requiredLevel: 0, // Minimum level required (0 means no requirement)
  category: ActivityCategory.dreamActivities, // Choose a suitable category
  displayOrder: 2, // Order in which it appears
  duration: 7, // Duration in minutes
  imagePath: 'assets/activities/my_new_activity_image.webp', // Image asset path
);

// ✅ UPDATE `initializeActivities()` TO INCLUDE NEW ACTIVITY
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
    myNewActivity, // ✅ ADD YOUR NEW ACTIVITY HERE
  ];
}

// ✅ SYNC ACTIVITIES WITH DATABASE
Future<void> syncActivities(Isar isar) async {
  final existingActivities = await isar.activitys.where().findAll();
  List<Activity> hardcodedActivities = initializeActivities();

  Map<ActivityId, Activity> existingActivitiesMap = {
    for (var activity in existingActivities) activity.activityId: activity
  };

  await isar.writeTxn(() async {
    for (var hardcodedActivity in hardcodedActivities) {
      if (existingActivitiesMap.containsKey(hardcodedActivity.activityId)) {
        final storedActivity = existingActivitiesMap[hardcodedActivity.activityId]!;

        if (_isActivityModi
