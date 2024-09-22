// File: lib/widgets/app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter_voice_friend/services/user_service.dart';

import '../models/activity.dart';
import '../screens/main_menu.dart';
import '../screens/settings_page.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Activity currentActivity;
  final int level;
  final Isar isar;
  final bool buildSettingButton;
  final bool buildMainMenuButton;
  final UserService userService;

  final Function(Activity) onActivityChanged;
  final Function(Map<String, dynamic>) onSettingChanged;

  const AppBarWidget({
    super.key,
    required this.currentActivity,
    required this.level,
    required this.isar,
    required this.buildSettingButton,
    required this.buildMainMenuButton,
    required this.onActivityChanged,
    required this.onSettingChanged,
    required this.userService,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('FlutterVoiceFriend - ${currentActivity.name}'),
      actions: [
        if (buildMainMenuButton)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainMenu(
                    currentLevel: level,
                    isar: isar,
                  ),
                ),
              );
              if (result != null && result is Activity) {
                onActivityChanged(result);
              }
            },
          ),
        if (buildSettingButton)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    userService: userService,
                    isar: isar,
                  ),
                ),
              );
              if (result != null && result is Map<String, dynamic>) {
                onSettingChanged(result);
              }
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
