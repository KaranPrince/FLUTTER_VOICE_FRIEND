// File: test/widgets/activity_item_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/activity/activity_item.dart';
import 'package:flutter_voice_friend/models/activity.dart';

void main() {
  testWidgets('ActivityItem displays activity name and image',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
        id: 1,
        activityId: ActivityId.dreamAnalyst,
        name: 'Test Activity',
        requiredLevel: 0,
        displayOrder: 0,
        category: ActivityCategory.dreamActivities,
        description: "test",
        imagePath: 'assets/activities/default_image.webp',
        duration: 25);
    bool onSelectCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityItem(
            activity: activity,
            onSelectActivity: () {
              onSelectCalled = true;
            },
            isCompleted: false,
            isUnlocked: true,
            lastCompleted: null,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Test Activity'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Act: Tap the activity
    await tester.tap(find.byType(ActivityItem));
    await tester.pumpAndSettle();

    // Assert callback
    expect(onSelectCalled, isTrue);
  });

  testWidgets('ActivityItem shows lock icon when isUnlocked is false',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
        id: 1,
        activityId: ActivityId.dreamAnalyst,
        name: 'Duration Activity',
        requiredLevel: 0,
        displayOrder: 0,
        category: ActivityCategory.dreamActivities,
        description: "test",
        imagePath: 'assets/activities/default_image.webp',
        duration: 25);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityItem(
            activity: activity,
            onSelectActivity: () {},
            isCompleted: false,
            isUnlocked: false,
            lastCompleted: null,
          ),
        ),
      ),
    );

    // Assert lock icon is present
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('ActivityItem shows checkmark when isCompleted is true',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
        id: 1,
        activityId: ActivityId.dreamAnalyst,
        name: 'Duration Activity',
        requiredLevel: 0,
        displayOrder: 0,
        category: ActivityCategory.dreamActivities,
        description: "test",
        imagePath: 'assets/activities/default_image.webp',
        duration: 25);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityItem(
            activity: activity,
            onSelectActivity: () {},
            isCompleted: true,
            isUnlocked: true,
            lastCompleted: DateTime.now(),
          ),
        ),
      ),
    );

    // Assert checkmark icon is present
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('ActivityItem shows duration tag', (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
        id: 1,
        activityId: ActivityId.dreamAnalyst,
        name: 'Duration Activity',
        requiredLevel: 0,
        displayOrder: 0,
        category: ActivityCategory.dreamActivities,
        description: "test",
        imagePath: 'assets/activities/default_image.webp',
        duration: 25);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityItem(
            activity: activity,
            onSelectActivity: () {},
            isCompleted: false,
            isUnlocked: true,
            lastCompleted: null,
          ),
        ),
      ),
    );

    // Assert duration text is present
    expect(find.text('25 min'), findsOneWidget);
  });
}
