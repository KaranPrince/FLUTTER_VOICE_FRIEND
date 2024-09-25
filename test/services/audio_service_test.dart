import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_voice_friend/services/audio_service.dart';
import 'package:flutter_voice_friend/utils/tts_openai_interface.dart';
import 'package:flutter_voice_friend/utils/tts_openai_justaudio.dart'
    as tts_justaudio;
import 'package:flutter_voice_friend/config.dart';
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

      expect(audioService.tts.runtimeType, tts_justaudio.TextToSpeechOpenAI);
      verify(mockTTS.dispose()).called(1);
    });

    test('Throws exception with unsupported backend', () {
      expect(
          () => audioService.initTTS('unsupported_backend'), throwsException);
    });
  });

  group('AudioService Intensity', () {
    test('Updates intensity and emits via intensityStream', () {
      // Mock the current intensity from TTS
      final intensityStream = audioService.intensityStream;

      // Expect the stream to emit a new intensity based on the calculation
      expectLater(intensityStream, emitsInOrder([0.05]));

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
      audioService
          .initStreams(); // This will start listening to the error stream
    });
  });

  group('AudioService Playback Controls', () {
    test('Plays text to speech successfully', () async {
      when(mockTTS.playTextToSpeech(any)).thenAnswer((_) async {});

      await audioService.playTextToSpeech('Hello World');

      verify(mockTTS.playTextToSpeech('Hello World')).called(1);
    });

    test('Handles errors during text to speech', () async {
      // Define the exception to be thrown
      final exception = Exception('TTS Error');

      // Mock the error stream to emit the exception
      when(mockTTS.errorStream)
          .thenAnswer((_) => Stream<Exception>.fromIterable([exception]));

      // Initialize the error stream listener
      audioService.initStreams();

      // Expect that the errorStream will emit the thrown exception
      expectLater(audioService.errorStream, emits(isA<Exception>()));

      // Trigger the playTextToSpeech function, which will cause the exception
      when(mockTTS.playTextToSpeech(any)).thenThrow(exception);
      await audioService.playTextToSpeech('Error Test');
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
    test('Properly disposes resources', () async {
      await audioService.dispose();

      verify(mockTTS.dispose()).called(1);
      // Since we can't access private members directly, we rely on the
      // behavior of public methods and check if the streams are closed indirectly.

      // Check if the streams are closed by attempting to listen to them
      // Check if intensityStream completes immediately (indicating closure)
      expectLater(audioService.intensityStream, emitsDone);

      // Check if errorStream completes immediately (indicating closure)
      expectLater(audioService.errorStream, emitsDone);
    });
  });
}
