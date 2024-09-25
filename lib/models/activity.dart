import 'package:isar/isar.dart';
import 'session.dart';

part 'activity.g.dart'; // Required for Isar code generation

enum ActivityCategory {
  dreamActivities,
}

enum ActivityId { introduction, dreamAnalyst }

@Collection()
class Activity {
  Id id; // Automatically incrementing ID in Isar

  @enumerated
  late ActivityId activityId;

  late String name; // Name of the activity

  late String description; // Description of the activity

  late int requiredLevel; // The level needed to unlock this activity

  late int displayOrder;

  late int duration; // The duration of the activity in minutes

  @enumerated
  late ActivityCategory category; // Storing enum directly in Isar

  @Backlink(to: 'activity')
  final sessions =
      IsarLinks<Session>(); // One-to-many relationship with Session

  late bool isCompleted; // Indicates whether the activity has been completed

  DateTime? lastCompleted; // The last time the user completed the activity

  late String imagePath; // Optional image for the activity icon

  // Constructor
  Activity({
    required this.activityId,
    required this.name,
    required this.description,
    required this.requiredLevel,
    required this.displayOrder,
    required this.category,
    required this.duration,
    this.id = Isar.autoIncrement,
    this.isCompleted = false,
    this.lastCompleted,
    this.imagePath = '',
  });
}
