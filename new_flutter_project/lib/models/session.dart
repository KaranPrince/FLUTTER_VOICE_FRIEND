import 'package:isar/isar.dart';
import 'activity.dart';

part 'session.g.dart'; // Required for Isar code generation

@Collection()
class Session {
  Id id = Isar.autoIncrement; // Automatically incrementing ID in Isar

  late DateTime date; // Date and time when the session took place

  late String
      conversationLog; // Log of the conversation with the AI agent (Whisper)

  late String sessionSummary; // Reflection on the meditation

  late int duration; // Duration of the session in minutes

  // Relation to the Activity entity (many-to-one relationship)
  final activity = IsarLink<Activity>();

  // Constructor
  Session({
    required this.date,
    this.conversationLog = '',
    this.sessionSummary = '',
    this.duration = 0,
  });
}
