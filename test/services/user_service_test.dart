import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UserService Tests', () {
    late UserService userService;

    setUp(() {
      userService = UserService();
      SharedPreferences.setMockInitialValues({});
    });

    test('Should load default user information', () async {
      await userService.loadUserInformation();

      expect(userService.selectedVoice, Config.defaultVoice);
      expect(userService.autoToggleRecording, false);
      expect(userService.selectedLanguage, Config.defaultLanguage);
    });

    test('Should save and load user information correctly', () async {
      await userService.updateUserInfo({
        'selectedVoice': 'nova',
        'autoToggleRecording': true,
        'selectedLanguage': 'FR',
      });

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selectedVoice'), 'nova');
      expect(prefs.getBool('autoToggleRecording'), true);
      expect(prefs.getString('selectedLanguage'), 'FR');

      await userService.loadUserInformation();

      expect(userService.selectedVoice, 'nova');
      expect(userService.autoToggleRecording, true);
      expect(userService.selectedLanguage, 'FR');
    });
  });
}
