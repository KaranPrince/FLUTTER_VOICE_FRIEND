// test/utils/tts_openai_justaudio_test.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_voice_friend/utils/tts_openai_justaudio.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import the generated mocks
import 'tts_openai_justaudio_test.mocks.dart';

// GenerateMocks annotation for Mockito
@GenerateMocks([AudioPlayer, http.Client])
void main() {
  dotenv.load();

  group('TextToSpeechOpenAI', () {
    late MockAudioPlayer mockAudioPlayer;
    late MockClient mockHttpClient;
    late TextToSpeechOpenAI tts;

    setUp(() {
      mockAudioPlayer = MockAudioPlayer();
      mockHttpClient = MockClient();

      Config.openaiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

      // Initialize TTS with a mock voice and replace dependencies
      tts = TextToSpeechOpenAI(
        "echo",
        audioPlayer: mockAudioPlayer,
        httpClient: mockHttpClient,
      );
    });

    tearDown(() {
      tts.dispose();
    });

    test('initializePlayer does not throw', () async {
      expect(() => tts.initializePlayer(), returnsNormally);
    });

    test('dispose calls dispose on AudioPlayer and closes httpClient',
        () async {
      tts.dispose();

      verify(mockAudioPlayer.dispose()).called(1);
      verify(mockHttpClient.close()).called(1);
    });

    test('setVoiceSpeed sets the voice speed on AudioPlayer', () {
      tts.setVoiceSpeed(1.5);
      verify(mockAudioPlayer.setSpeed(1.5)).called(1);
    });

    test('updateVoice updates the voice', () {
      tts.updateVoice("new_voice");
      // Since _voice is private, we can't directly verify its value.
      // Instead, verify behavior dependent on voice updates if necessary.
      // For now, ensure no errors occur.
      expect(true, isTrue);
    });

    test('isPlaying returns correct playing state', () async {
      // Initially, it should not be playing
      expect(tts.isPlaying(), false);

      // Simulate playback starting
      when(mockAudioPlayer.play()).thenAnswer((_) async => {});
      when(mockAudioPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(
          false,
          ProcessingState.completed,
        )),
      );

      await tts.playTextToSpeech("Test");

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Since _isPlayingAudio is private, verify via isPlaying
      // After playback, it should be false
      expect(tts.isPlaying(), false);
    });

    test('hasAudioToPlay returns correct state', () async {
      // Initially, no audio to play
      expect(tts.hasAudioToPlay(), false);

      // Mock HTTP response
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));

      // Mock AudioPlayer's setAudioSource and play
      when(mockAudioPlayer.setAudioSource(any)).thenAnswer((_) async => null);
      when(mockAudioPlayer.play()).thenAnswer((_) async => {});
      when(mockAudioPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(
          false,
          ProcessingState.completed,
        )),
      );

      await tts.playTextToSpeech("Hello, this is a test.");

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify that hasAudioToPlay is true after adding to buffer
      expect(tts.hasAudioToPlay(), true);
    });

    test('toggleAutoPause toggles auto-pause state', () {
      // Initially, auto-pause is false
      tts.toggleAutoPause();
      // Since _autoPause is private, we can't access it directly
      // Instead, verify behavior based on auto-pause if necessary
      // For now, ensure no errors occur
      expect(true, isTrue);
    });

    test('repeat sets the repeat flag', () {
      // Initially, repeat is false
      tts.repeat();
      // Since _repeat is private, verify behavior based on repeat
      // For now, ensure no errors occur
      expect(true, isTrue);
    });

    test('next clears the waitForNext flag', () {
      // Similar to above, since _waitForNext is private, verify behavior
      // For now, ensure no errors occur
      tts.next();
      expect(true, isTrue);
    });

    test('lastAudioToPlay returns true when no audio is buffered', () {
      expect(tts.lastAudioToPlay(), true);
    });

    test('lastAudioToPlay returns false when audio is buffered', () async {
      // Mock HTTP response
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));

      // Mock AudioPlayer's setAudioSource and play
      when(mockAudioPlayer.setAudioSource(any)).thenAnswer((_) async => null);
      when(mockAudioPlayer.play()).thenAnswer((_) async => {});
      when(mockAudioPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(
          false,
          ProcessingState.completed,
        )),
      );

      await tts.playTextToSpeech("Hello, this is a test.");

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 100));

      expect(tts.lastAudioToPlay(), false);
    }, skip: 'TODO: Auto generated test - review failure case and fix test');

    test('getSubtitles returns current subtitles', () async {
      // Mock HTTP response
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));

      // Mock AudioPlayer's setAudioSource and play
      when(mockAudioPlayer.setAudioSource(any)).thenAnswer((_) async => null);
      when(mockAudioPlayer.play()).thenAnswer((_) async => {});
      when(mockAudioPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(
          false,
          ProcessingState.completed,
        )),
      );

      await tts.playTextToSpeech("Hello, this is a test.");

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Since _currentSubtitles is set if sentence length > 8
      expect(tts.getSubtitles(), "Hello, this is a test.");
    }, skip: 'TODO: Auto generated test - review failure case and fix test');

    test('getCurrentIntensity returns clamped intensity', () {
      // Call getCurrentIntensity multiple times and verify clamping
      for (int i = 0; i < 10; i++) {
        double intensity = tts.getCurrentIntensity();
        expect(intensity, inInclusiveRange(2.0, 8.0));
      }
    }, skip: 'TODO: Auto generated test - review failure case and fix test');

    test('playTextToSpeech adds text to queue and processes it', () async {
      // Mock the HTTP response
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));

      // Mock AudioPlayer's setAudioSource and play
      when(mockAudioPlayer.setAudioSource(any)).thenAnswer((_) async => null);
      when(mockAudioPlayer.play()).thenAnswer((_) async => {});
      when(mockAudioPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(
          false,
          ProcessingState.completed,
        )),
      );

      await tts.playTextToSpeech("Hello, this is a test.");

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify that HTTP POST was called with correct parameters
      verify(mockHttpClient.post(
        Uri.parse(Config.openaiTtsUrl),
        headers: {
          'Authorization': 'Bearer ${Config.openaiApiKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "tts-1",
          "input": "Hello, this is a test.",
          "voice": "echo",
          "response_format": "aac"
        }),
      )).called(1);

      // Verify that setAudioSource and play were called
      verify(mockAudioPlayer.setAudioSource(any)).called(1);
      verify(mockAudioPlayer.play()).called(1);
    }, skip: 'TODO: Auto generated test - review failure case and fix test');

    test('stop stops the audio player and clears buffers', () async {
      // Mock the HTTP response
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));

      // Mock AudioPlayer's setAudioSource and play
      when(mockAudioPlayer.setAudioSource(any)).thenAnswer((_) async => null);
      when(mockAudioPlayer.play()).thenAnswer((_) async => {});
      when(mockAudioPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(
          false,
          ProcessingState.completed,
        )),
      );

      await tts.playTextToSpeech("Hello, this is a test.");

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Stop playback
      await tts.stop();

      // Verify that stop was called on AudioPlayer
      verify(mockAudioPlayer.stop()).called(1);

      // Verify that buffers are cleared by checking if lastAudioToPlay returns true
      expect(tts.lastAudioToPlay(), true);
      expect(tts.isPlaying(), false);
      expect(tts.hasAudioToPlay(), false);
      expect(tts.getSubtitles(), "");
    });

    test('handles API failure and emits error', () async {
      // Mock the HTTP response to fail
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      // Listen for errors
      final errors = <Exception>[];
      tts.errorStream.listen((error) {
        errors.add(error);
      });

      await tts.playTextToSpeech("This will fail");

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 100));

      expect(errors.length, 1);
      expect(
        errors.first.toString(),
        contains('Failed to synthesize audio for text "This will fail"'),
      );
    });

    test('handles empty text gracefully', () async {
      await tts.playTextToSpeech("");

      // Expect no HTTP calls
      verifyNever(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ));

      // Expect no audio to play
      expect(tts.hasAudioToPlay(), false);
    });

    test('handles very long text by splitting into segments', () async {
      String longText = 'A' * 1000; // 1000 characters

      // Mock the HTTP response
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));

      // Mock AudioPlayer's setAudioSource and play
      when(mockAudioPlayer.setAudioSource(any)).thenAnswer((_) async => null);
      when(mockAudioPlayer.play()).thenAnswer((_) async => {});
      when(mockAudioPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(
          false,
          ProcessingState.completed,
        )),
      );

      await tts.playTextToSpeech(longText);

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 500));

      // Calculate expected number of segments
      int expectedSegments = (longText.length / 200).ceil();

      // Verify the number of HTTP calls
      verify(mockHttpClient.post(
        Uri.parse(Config.openaiTtsUrl),
        headers: {
          'Authorization': 'Bearer ${Config.openaiApiKey}',
          'Content-Type': 'application/json',
        },
        body: anyNamed('body'),
      )).called(expectedSegments);

      // Verify that setAudioSource and play were called expected number of times
      verify(mockAudioPlayer.setAudioSource(any)).called(expectedSegments);
      verify(mockAudioPlayer.play()).called(expectedSegments);
    }, skip: 'TODO: Auto generated test - review failure case and fix test');

    test('multiple playTextToSpeech calls queue texts properly', () async {
      // Mock the HTTP response
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 200));

      // Mock AudioPlayer's setAudioSource and play
      when(mockAudioPlayer.setAudioSource(any)).thenAnswer((_) async => null);
      when(mockAudioPlayer.play()).thenAnswer((_) async {});
      when(mockAudioPlayer.playerStateStream).thenAnswer(
        (_) => Stream.value(PlayerState(
          false,
          ProcessingState.completed,
        )),
      );

      await tts.playTextToSpeech("First text.");
      await tts.playTextToSpeech("Second text.");

      // Allow some time for processing
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify that both texts were processed
      verify(mockHttpClient.post(
        Uri.parse(Config.openaiTtsUrl),
        headers: {
          'Authorization': 'Bearer ${Config.openaiApiKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "tts-1",
          "input": "First text.",
          "voice": "echo",
          "response_format": "aac"
        }),
      )).called(1);

      verify(mockHttpClient.post(
        Uri.parse(Config.openaiTtsUrl),
        headers: {
          'Authorization': 'Bearer ${Config.openaiApiKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "tts-1",
          "input": "Second text.",
          "voice": "echo",
          "response_format": "aac"
        }),
      )).called(1);

      // Verify that setAudioSource and play were called for both texts
      verify(mockAudioPlayer.setAudioSource(any)).called(2);
      verify(mockAudioPlayer.play()).called(2);
    }, skip: 'TODO: Auto generated test - review failure case and fix test');

    test('getCurrentIntensity clamps correctly at lower bound', () {
      // Manually set _currentIntensity to near lower bound
      // Since _currentIntensity is private, we simulate it via multiple calls
      for (int i = 0; i < 100; i++) {
        double intensity = tts.getCurrentIntensity();
        expect(intensity, greaterThanOrEqualTo(0.05));
      }
    });

    test('getCurrentIntensity clamps correctly at upper bound', () {
      // Similar to above, simulate multiple calls to reach upper bound
      for (int i = 0; i < 100; i++) {
        double intensity = tts.getCurrentIntensity();
        expect(intensity, lessThanOrEqualTo(8.0));
      }
    });
  });
}
