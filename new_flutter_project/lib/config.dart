// File: lib/config.dart
import 'dart:io' show Platform;

class Config {
  static late String openaiApiKey;
  static late String deepgramApiKey;

  static bool debug = false;

  static const String openaiTtsUrl = 'https://api.openai.com/v1/audio/speech';

  static const String defaultLanguage = 'EN';
  static final String defaultStt = Platform.isIOS ? onDeviceStt : deepgramStt;
  static const String defaultVoice = voiceNova;

  static const String deepgramStt = "Deepgram";
  static const String onDeviceStt = 'On Device';

  static const String soloudBackend = "SoLoud";
  static const String justAudioBackend = 'just_audio';

  static const String voiceAlloy = "alloy";
  static const String voiceEcho = "echo";
  static const String voiceFable = "fable";
  static const String voiceOnyx = "onyx";
  static const String voiceNova = "nova";
  static const String voiceShimmer = "shimmer";

  static const Map<String, String> languageCodeMap = {
    'EN': 'en-US',
    'FR': 'fr-FR',
    'ES': 'es-ES',
  };

  static const Map<String, String> languageStringToAdd = {
    'EN': 'Please give your response in English',
    'FR': 'Please give your response in French',
    'ES': 'Please give your response in Spanish',
  };
}
