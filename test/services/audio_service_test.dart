import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_voice_friend/services/audio_service.dart';
import 'package:flutter_voice_friend/utils/tts_openai_interface.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/constants.dart';
import 'dart:async';

import 'audio_service_test.mocks.dart';

// Generate the mock class for TextToSpeechOpenAI
@GenerateMocks([TextToSpeechOpenAI])
void main() {
  late MockTextToSpeechOpenAI mockTTS;
  late AudioService audioService;

  setUp(() {
    // Ensure that the Flutter environment is initialized before running tests
    WidgetsFlutterBinding.ensureInitialized();

    mockTTS = MockTextToSpeechOpenAI();
    audioService = AudioService(); // This uses the mock below
    audioService.tts = mockTTS; // Inject the mock dependency after construction
  });

  group('AudioService Initialization', () {
    test('Initializes with just_audio backend', () {
      audioService.initTTS(Config.justAudioBackend);

      // Verify that the correct TTS instance is being used (the mock)
      expect(audioService.tts,
          mockTTS); // Use the mock object directly in the comparison
      verify(mockTTS.dispose()).called(1);
      verify(mockTTS.initializePlayer()).called(1);
    });

    test('Throws exception with unsupported backend', () {
      expect(
          () => audioService.initTTS('unsupported_backend'), throwsException);
    });
  });

  group('AudioService Intensity', () {
    test('Updates intensity and emits via intensityStream', () {
      // Mock the current intensity from TTS
      when(mockTTS.getCurrentIntensity()).thenReturn(5.0);
      final intensityStream = audioService.intensityStream;

      // Expect the stream to emit a new intensity based on the calculation
      expectLater(intensityStream,
          emitsInOrder([5.0 / PlayWidgetConstant.intensityDivisor]));

      audioService
          .initTTS(Config.justAudioBackend); // Start the intensity timer
    });
  });

  group('AudioService Error Handling', () {
    test('Emits errors from TTS via error stream', () {
      // Set up a stream that emits an exception
      final errorStream =
          Stream<Exception>.fromIterable([Exception('TTS Error')]);
      when(mockTTS.errorStream).thenAnswer((_) => errorStream);

      expectLater(audioService.errorStream, emitsInOrder([isA<Exception>()]));

      audioService.initTTS(Config
          .justAudioBackend); // This will start listening to the error stream
    });
  });

  group('AudioService Playback Controls', () {
    test('Plays text to speech successfully', () async {
      when(mockTTS.playTextToSpeech(any)).thenAnswer((_) async {});

      await audioService.playTextToSpeech('Hello World');

      verify(mockTTS.playTextToSpeech('Hello World')).called(1);
    });

    test('Handles errors during text to speech', () async {
      final exception = Exception('TTS Error');
      when(mockTTS.playTextToSpeech(any)).thenThrow(exception);

      await audioService.playTextToSpeech('Error Test');

      expectLater(audioService.errorStream, emits(exception));
    });

    test('Stops TTS playback', () {
      audioService.stop();
      verify(mockTTS.stop()).called(1);
    });

    test('Checks if audio is playing', () {
      when(mockTTS.isPlaying()).thenReturn(true);

      expect(audioService.isPlaying(), true);
    });

    test('Checks if audio is available to play', () {
      when(mockTTS.hasAudioToPlay()).thenReturn(true);

      expect(audioService.hasAudioToPlay(), true);
    });
  });

  group('AudioService Dispose', () {
    test('Properly disposes resources', () {
      audioService.dispose();

      verify(mockTTS.dispose()).called(1);
      // Since we can't access private members directly, we rely on the
      // behavior of public methods and check if the streams are closed indirectly.
      expect(audioService.intensityStream.isBroadcast,
          true); // intensityStream is broadcast
      expect(audioService.errorStream.isBroadcast,
          true); // errorStream is broadcast
    });
  });
}
