import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/services/speech_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'speech_service_test.mocks.dart';

@GenerateMocks([Deepgram, stt.SpeechToText])
void main() {
  dotenv.load();
  group('SpeechService Tests', () {
    late SpeechService speechService;
    late MockDeepgram mockDeepgram;
    late MockSpeechToText mockSpeechToText;

    setUp(() {
      speechService = SpeechService();
      mockDeepgram = MockDeepgram();
      mockSpeechToText = MockSpeechToText();

      Config.deepgramApiKey = dotenv.env['DEEPGRAM_API_KEY'] ?? '';
    });

    test('Should initialize Deepgram successfully', () async {
      when(mockDeepgram.isApiKeyValid()).thenAnswer((_) async => true);
      await speechService.initialize(Config.deepgramStt);

      expect(speechService.errorController.isClosed, false);
    });

    test('Should handle Deepgram initialization failure', () async {
      when(mockDeepgram.isApiKeyValid())
          .thenThrow(Exception('Invalid API Key'));
      speechService.errorStream.listen((error) {
        expect(error, isA<Exception>());
      });

      await speechService.initialize(Config.deepgramStt);
    });

    // Add tests for on-device speech recognition initialization
    // Tests for startListening and stopListening methods
  });
}
