// File: lib/services/user_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../activities.dart';
import '../config.dart';

class UserService extends ChangeNotifier {
  String selectedLanguage = Config.defaultLanguage;
  String selectedSpeechToTextMethod = Config.defaultStt;
  String selectedAudioBackend =
      (kIsWeb) ? Config.justAudioBackend : Config.soloudBackend;
  String selectedVoice = Config.defaultVoice;
  double voiceSpeed = 0.9;
  bool autoToggleRecording = false;
  int level = 0;
  Activity currentActivity = introductionActivity;
  String userInformation = "";

  Future<void> loadUserInformation() async {
    debugPrint("_loadUserInformation");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    selectedVoice = prefs.getString('selectedVoice') ?? selectedVoice;
    autoToggleRecording =
        prefs.getBool('autoToggleRecording') ?? autoToggleRecording;
    selectedLanguage = prefs.getString('selectedLanguage') ?? selectedLanguage;
    selectedSpeechToTextMethod =
        prefs.getString('selectedSpeechToTextMethod') ??
            selectedSpeechToTextMethod;
    selectedAudioBackend =
        prefs.getString('selectedAudioBackend') ?? selectedAudioBackend;
    userInformation = prefs.getString('userInformation') ?? userInformation;
    level = prefs.getInt('level') ?? level;
    voiceSpeed = prefs.getDouble('voiceSpeed') ?? voiceSpeed;

    notifyListeners();
  }

  Future<void> saveUserInformation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedVoice', selectedVoice);
    prefs.setBool('autoToggleRecording', autoToggleRecording);
    prefs.setString('selectedLanguage', selectedLanguage);
    prefs.setString('selectedSpeechToTextMethod', selectedSpeechToTextMethod);
    prefs.setString('selectedAudioBackend', selectedAudioBackend);
    prefs.setString('userInformation', userInformation);
    prefs.setInt('level', level);
    prefs.setDouble('voiceSpeed', voiceSpeed);
  }

  Future<void> updateUserInfo(Map<String, dynamic> userInfo) async {
    selectedVoice = userInfo['selectedVoice'] ?? selectedVoice;

    autoToggleRecording =
        userInfo['autoToggleRecording'] ?? autoToggleRecording;
    selectedLanguage = userInfo['selectedLanguage'] ?? selectedLanguage;

    selectedSpeechToTextMethod =
        userInfo['selectedSpeechToTextMethod'] ?? selectedSpeechToTextMethod;

    selectedAudioBackend =
        userInfo['selectedAudioBackend'] ?? selectedAudioBackend;

    userInformation = userInfo['userInformation'] ?? userInformation;
    level = userInfo['selectedLevel'] ?? level;
    voiceSpeed = userInfo['selectedVoiceSpeed'] ?? voiceSpeed;
    await saveUserInformation();
  }

  void updateCurrentActivity(Activity activity) {
    currentActivity = activity;
    notifyListeners();
  }
}
