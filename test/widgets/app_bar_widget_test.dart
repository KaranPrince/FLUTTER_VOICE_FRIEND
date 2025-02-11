// File: test/widgets/app_bar_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/widgets/app_bar_widget.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:isar/isar.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'app_bar_widget_test.mocks.dart';
import 'package:flutter_voice_friend/services/user_service.dart';

// Generate mocks using mockito
@GenerateMocks([Isar, UserService])
void main() {
  // Initialize mocks
  late MockIsar mockIsar;
  late MockUserService mockUserService;

  setUp(() {
    mockIsar = MockIsar();
    mockUserService = MockUserService();

    // Mock the UserService properties using the values from Config
    when(mockUserService.selectedLanguage).thenReturn(Config.defaultLanguage);
    when(mockUserService.selectedSpeechToTextMethod)
        .thenReturn(Config.defaultStt);
    when(mockUserService.selectedAudioBackend)
        .thenReturn(Config.justAudioBackend);
    when(mockUserService.selectedVoice).thenReturn(Config.defaultVoice);
    when(mockUserService.voiceSpeed).thenReturn(0.9);
    when(mockUserService.autoToggleRecording).thenReturn(false);
    when(mockUserService.level).thenReturn(0);
    when(mockUserService.userInformation).thenReturn("");
  });

  testWidgets('AppBarWidget displays correct title',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
      id: 1,
      name: 'Test Activity',
      imagePath: 'assets/activities/default_image.webp',
      duration: 10,
      activityId: ActivityId.introduction,
      description: 'Introduction activity',
      requiredLevel: 0,
      category: ActivityCategory.dreamActivities,
      displayOrder: 0,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBarWidget(
            currentActivity: activity,
            level: 1,
            isar: mockIsar,
            buildSettingButton: false,
            buildMainMenuButton: false,
            onActivityChanged: (Activity a) {},
            onSettingChanged: (Map<String, dynamic> m) {},
            userService: mockUserService,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('FlutterVoiceFriend - Test Activity'), findsOneWidget);
  });

  testWidgets(
      'AppBarWidget shows main menu button when buildMainMenuButton is true',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
      id: 1,
      name: 'Test Activity',
      imagePath: 'assets/activities/default_image.webp',
      duration: 10,
      activityId: ActivityId.introduction,
      description: 'Introduction activity',
      requiredLevel: 0,
      category: ActivityCategory.dreamActivities,
      displayOrder: 0,
    );
    bool activityChanged = false;
    Activity? selectedActivity;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBarWidget(
            currentActivity: activity,
            level: 1,
            isar: mockIsar,
            buildSettingButton: false,
            buildMainMenuButton: true,
            onActivityChanged: (Activity a) {
              activityChanged = true;
              selectedActivity = a;
            },
            onSettingChanged: (Map<String, dynamic> m) {},
            userService: mockUserService,
          ),
        ),
      ),
    );

    // Assert main menu button is present
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // Act: Tap the main menu button
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Since the actual navigation pushes MainMenu widget, to simplify, assume navigation works
    // Or you can mock Navigator

    // For this example, just check if navigation happens by checking if 'Main Menu' text is shown
    expect(find.text('Select an Activity'), findsOneWidget);
  });

  testWidgets(
      'AppBarWidget shows settings button when buildSettingButton is true',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
      id: 1,
      name: 'Test Activity',
      imagePath: 'assets/activities/default_image.webp',
      duration: 10,
      activityId: ActivityId.introduction,
      description: 'Introduction activity',
      requiredLevel: 0,
      category: ActivityCategory.dreamActivities,
      displayOrder: 0,
    );
    bool settingsChanged = false;
    Map<String, dynamic>? settings;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBarWidget(
            currentActivity: activity,
            level: 1,
            isar: mockIsar,
            buildSettingButton: true,
            buildMainMenuButton: false,
            onActivityChanged: (Activity a) {},
            onSettingChanged: (Map<String, dynamic> m) {
              settingsChanged = true;
              settings = m;
            },
            userService: mockUserService,
          ),
        ),
      ),
    );

    // Assert settings button is present
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Act: Tap the settings button
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Check if 'Settings Page' is shown
    expect(find.text('Settings'), findsAtLeast(1));
  });

  testWidgets(
      'AppBarWidget calls onActivityChanged when main menu returns an Activity',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
      id: 1,
      name: 'Test Activity',
      imagePath: 'assets/activities/default_image.webp',
      duration: 10,
      activityId: ActivityId.introduction,
      description: 'Introduction activity',
      requiredLevel: 0,
      category: ActivityCategory.dreamActivities,
      displayOrder: 0,
    );
    final newActivity = Activity(
      id: 1,
      name: 'Test Activity',
      imagePath: 'assets/activities/default_image.webp',
      duration: 10,
      activityId: ActivityId.introduction,
      description: 'Introduction activity',
      requiredLevel: 0,
      category: ActivityCategory.dreamActivities,
      displayOrder: 0,
    );
    bool activityChanged = false;
    Activity? selectedActivity;

    // Create a mock navigator that returns newActivity when MainMenu is popped
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBarWidget(
            currentActivity: activity,
            level: 1,
            isar: mockIsar,
            buildSettingButton: false,
            buildMainMenuButton: true,
            onActivityChanged: (Activity a) {
              activityChanged = true;
              selectedActivity = a;
            },
            onSettingChanged: (Map<String, dynamic> m) {},
            userService: mockUserService,
          ),
        ),
      ),
    );

    // Act: Tap the main menu button
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Simulate returning newActivity from MainMenu
    Navigator.pop(tester.element(find.text('Select an Activity')), newActivity);
    await tester.pumpAndSettle();

    // Assert
    expect(activityChanged, isTrue);
    expect(selectedActivity, equals(newActivity));
  });

  testWidgets('AppBarWidget calls onSettingChanged when settings returns a Map',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity(
      id: 1,
      name: 'Test Activity',
      imagePath: 'assets/activities/default_image.webp',
      duration: 10,
      activityId: ActivityId.introduction,
      description: 'Introduction activity',
      requiredLevel: 0,
      category: ActivityCategory.dreamActivities,
      displayOrder: 0,
    );
    final settingsMap = {'theme': 'dark'};
    bool settingChanged = false;
    Map<String, dynamic>? receivedSettings;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBarWidget(
            currentActivity: activity,
            level: 1,
            isar: mockIsar,
            buildSettingButton: true,
            buildMainMenuButton: false,
            onActivityChanged: (Activity a) {},
            onSettingChanged: (Map<String, dynamic> m) {
              settingChanged = true;
              receivedSettings = m;
            },
            userService: mockUserService,
          ),
        ),
      ),
    );

    // Act: Tap the settings button
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Simulate returning settingsMap from SettingsPage
    Navigator.pop(tester.element(find.text('Settings Page')), settingsMap);
    await tester.pumpAndSettle();

    // Assert
    expect(settingChanged, isTrue);
    expect(receivedSettings, equals(settingsMap));
  });
}
