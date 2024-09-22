import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:flutter_voice_friend/models/session.dart';

class SessionService {
  final Isar isar;

  SessionService({required this.isar});

  Future<void> updateActivity(Activity activity) async {
    final Activity? currentActivityFromDb = await isar.activitys
        .filter()
        .activityIdEqualTo(activity.activityId)
        .findFirst();

    if (currentActivityFromDb == null) {
      throw Exception("Activity not found in the database");
    }

    await isar.writeTxn(() async {
      currentActivityFromDb.isCompleted = true;
      currentActivityFromDb.lastCompleted = DateTime.now();

      await isar.activitys.put(currentActivityFromDb);
    });
  }

  Future<void> saveSession(String conversationLog, String sessionSummary,
      DateTime sessionStartTime, Activity activity) async {
    DateTime sessionEndTime = DateTime.now();
    Duration sessionDuration = sessionEndTime.difference(sessionStartTime);
    int durationInMinutes = sessionDuration.inMinutes;

    final sessionCollection = isar.sessions;
    final activityCollection = isar.activitys;

    final currentActivityFromDb = await activityCollection.get(activity.id);

    if (currentActivityFromDb == null) {
      throw Exception("Activity not found in the database");
    }

    Session session = Session(
      date: DateTime.now(),
      conversationLog: conversationLog,
      duration: durationInMinutes,
      sessionSummary: sessionSummary,
    );

    await isar.writeTxn(() async {
      await sessionCollection.put(session);

      session.activity.value = currentActivityFromDb;
      await session.activity.save();

      currentActivityFromDb.isCompleted = true;
      currentActivityFromDb.lastCompleted = DateTime.now();

      currentActivityFromDb.sessions.add(session);
      await currentActivityFromDb.sessions.save();

      await activityCollection.put(currentActivityFromDb);
    });

    debugPrint('Session saved successfully with ID: ${session.id}');
    debugPrint(
        'Activity updated with session count: ${currentActivityFromDb.sessions.length}');
  }

  Future<String> generateUserActivitySummary(Activity currentActivity) async {
    final Activity? activity = await isar.activitys
        .filter()
        .activityIdEqualTo(currentActivity.activityId)
        .findFirst();

    if (activity == null) {
      return "Activity not found.";
    }

    await activity.sessions.load();

    List<Session> sortedSessions = List<Session>.from(activity.sessions)
      ..sort((a, b) => a.date.compareTo(b.date));

    StringBuffer conversationLogBuffer = StringBuffer();
    DateTime now = DateTime.now();

    for (Session session in sortedSessions) {
      Duration timeSinceSession = now.difference(session.date);
      String timeSinceSessionStr = _formatDuration(timeSinceSession);

      conversationLogBuffer.writeln("Date: $timeSinceSessionStr");
      conversationLogBuffer.writeln("Duration: ${session.duration} minute(s)");
      conversationLogBuffer
          .writeln("Conversation Log:\n${session.sessionSummary}");
      conversationLogBuffer
          .writeln("---------------------------------------------------\n");
    }

    if (conversationLogBuffer.isEmpty) {
      return "No conversations available for the specified activity.";
    }

    return conversationLogBuffer.toString();
  }

  Future<int> getLastSessionId() async {
    final sessionCollection = isar.sessions;

    List<Session> allSessions =
        await sessionCollection.where().sortByDateDesc().findAll();
    if (allSessions.isEmpty) {
      return -1;
    }
    return allSessions[0].id;
  }

  Future<int> getLastSessionIdForActivity(ActivityId activityId) async {
    final Activity? fetchedActivity =
        await isar.activitys.filter().activityIdEqualTo(activityId).findFirst();
    if (fetchedActivity == null) {
      return -1;
    }
    await fetchedActivity.sessions.load();
    List<Session> sortedSessions = List<Session>.from(fetchedActivity.sessions)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedSessions.isNotEmpty) {
      return sortedSessions.first.id;
    }

    return -1;
  }

  Future<String> getAllConversationsFromActivityWithDetails(
      ActivityId activityId, int fromSessionId) async {
    final Activity? activity =
        await isar.activitys.filter().activityIdEqualTo(activityId).findFirst();

    if (activity == null) {
      return "Activity not found.";
    }

    await activity.sessions.load();

    List<Session> sortedSessions = List<Session>.from(activity.sessions)
      ..sort((a, b) => b.date.compareTo(a.date));

    StringBuffer conversationLogBuffer = StringBuffer();
    DateTime now = DateTime.now();

    for (Session session in sortedSessions) {
      if (session.id == fromSessionId) {
        break;
      }
      Duration timeSinceSession = now.difference(session.date);
      String timeSinceSessionStr = _formatDuration(timeSinceSession);

      conversationLogBuffer.writeln("Date: ${session.date}");
      conversationLogBuffer.writeln("Occurred: $timeSinceSessionStr");
      conversationLogBuffer.writeln("Duration: ${session.duration} minute(s)");
      conversationLogBuffer.writeln("Activity: ${activity.name}");
      conversationLogBuffer
          .writeln("Conversation Log:\n${session.conversationLog}");
      conversationLogBuffer
          .writeln("---------------------------------------------------\n");
    }

    if (conversationLogBuffer.isEmpty) {
      return "No conversations available for the specified activity after the given session ID.";
    }

    return conversationLogBuffer.toString();
  }

  Future<String> getAllConversationsWithDetails(
      int fromSession, ActivityCategory category) async {
    final sessionCollection = isar.sessions;

    List<Session> allSessions =
        await sessionCollection.where().sortByDateDesc().findAll();

    if (allSessions.isEmpty) {
      return "No conversations available.";
    }

    StringBuffer conversationLogBuffer = StringBuffer();

    DateTime now = DateTime.now();

    for (var session in allSessions) {
      if (session.id == fromSession) break;
      await session.activity.load();

      Activity? activity = session.activity.value;

      if (activity == null || activity.category != category) {
        continue;
      }

      String activityName = activity.name;

      Duration timeSinceSession = now.difference(session.date);
      String timeSinceSessionStr = _formatDuration(timeSinceSession);

      conversationLogBuffer.writeln("Date: ${session.date}");
      conversationLogBuffer.writeln("Occurred: $timeSinceSessionStr");
      conversationLogBuffer.writeln("Duration: ${session.duration} minute(s)");
      conversationLogBuffer.writeln("Activity: $activityName");
      conversationLogBuffer
          .writeln("Conversation Log:\n${session.conversationLog}");
      conversationLogBuffer
          .writeln("---------------------------------------------------\n");
    }

    return conversationLogBuffer.toString();
  }

  String _formatDuration(Duration duration) {
    int days = duration.inDays;
    int years = days ~/ 365;
    int months = (days % 365) ~/ 30;
    int weeks = (days % 365) % 30 ~/ 7;

    if (years > 0) {
      return "$years year(s) ago";
    } else if (months > 0) {
      return "$months month(s) ago";
    } else if (weeks > 0) {
      return "$weeks week(s) ago";
    } else if (days > 0) {
      return "$days day(s) ago";
    } else if (duration.inHours > 0) {
      return "${duration.inHours} hour(s) ago";
    } else {
      return "${duration.inMinutes} minute(s) ago";
    }
  }
}
