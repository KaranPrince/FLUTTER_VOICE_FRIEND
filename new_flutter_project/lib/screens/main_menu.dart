import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/activity.dart';
import '../widgets/activity/activity_item.dart';

class MainMenu extends StatelessWidget {
  final int currentLevel;
  final Isar isar; // Change Store to Isar

  const MainMenu({super.key, required this.isar, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select an Activity'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dream Activities'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Kids Activities Tab
            FutureBuilder<List<Activity>>(
              future: getActivitiesByCategory(
                  ActivityCategory.dreamActivities, isar),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ActivityGrid(
                      activities: snapshot.data!,
                      currentLevel: currentLevel,
                    );
                  } else {
                    return const Center(child: Text('No activities found.'));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Function to fetch activities by category from Isar
Future<List<Activity>> getActivitiesByCategory(
    ActivityCategory category, Isar isar) async {
  // Query the activities by category and sort them by displayOrder
  return await isar.activitys
      .filter()
      .categoryEqualTo(category)
      .sortByDisplayOrder()
      .findAll();
}

class ActivityGrid extends StatelessWidget {
  final List<Activity> activities;
  final int currentLevel;

  const ActivityGrid({
    super.key,
    required this.activities,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: activities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) {
        final activity = activities[index];
        final bool isUnlocked = activity.requiredLevel <= currentLevel;

        return Opacity(
          opacity: isUnlocked ? 1.0 : 0.25,
          child: GestureDetector(
            onTap: isUnlocked
                ? () {
                    Navigator.pop(context, activity);
                  }
                : null,
            child: ActivityItem(
              activity: activity,
              isUnlocked: isUnlocked,
              isCompleted: activity.isCompleted,
              lastCompleted: activity.lastCompleted,
              onSelectActivity: isUnlocked
                  ? () {
                      Navigator.pop(context, activity);
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }
}

Future<void> navigateToMainMenu(BuildContext context, int currentLevel,
    Isar isar, Function(Activity) updateChain) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MainMenu(currentLevel: currentLevel, isar: isar),
    ),
  );

  if (result != null && result is Activity) {
    updateChain(result);
  }
}
