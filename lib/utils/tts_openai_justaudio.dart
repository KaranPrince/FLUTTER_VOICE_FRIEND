// lib/utils/tts_openai_justaudio.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/utils/tts_openai_interface.dart'
    as tts_interface;

class TextToSpeechOpenAI implements tts_interface.TextToSpeechOpenAI {
  // Constants
  static const double minIntensity = 0.05;
  static const double _defaultSpeakingIntensity = 5.0;
  static const int _maxCharacters = 200;
  static const Duration _pauseBetweenSentences = Duration(milliseconds: 300);
  static const Duration _pauseBetweenPauses = Duration(milliseconds: 1500);
  static const String _pauseMarker = "[pause]";
  static const String _endMarker = "[END]";

  // Queues for managing text and audio
  final Queue<String> _queue = Queue<String>();
  final AudioPlayer _audioPlayer;
  final http.Client _httpClient;
  final Queue<Future<Uint8List?>> _audioBuffer = Queue<Future<Uint8List?>>();
  final Queue<String> _textBuffer = Queue<String>();

  // Playback control flags
  bool _hasAudioToPlay = false;
  bool _isPlayingAudio = false;
  bool _autoPause = false;
  bool _waitForNext = false;
  bool _repeat = false;

  // Intensity metrics
  double _currentIntensity = minIntensity;

  // Voice settings
  String _voice;
  double _voiceSpeed = 1.0;

  // Subtitles
  String _currentSubtitles = "";

  // Timer for intensity (if needed in the future)
  Timer? _audioIntensityTimer;

  // StreamController to emit errors
  final StreamController<Exception> _errorController =
      StreamController<Exception>.broadcast();

  // Expose the error stream
  @override
  Stream<Exception> get errorStream => _errorController.stream;

  TextToSpeechOpenAI(
    this._voice, {
    AudioPlayer? audioPlayer,
    http.Client? httpClient,
  })  : _audioPlayer = audioPlayer ?? AudioPlayer(),
        _httpClient = httpClient ?? http.Client() {
    _audioPlayer.setVolume(1.0);
    _audioPlayer.setLoopMode(LoopMode.off);
    _audioPlayer.setSpeed(_voiceSpeed);
  }

  @override
  Future<void> initializePlayer() async {
    // No-op: No initialization needed
  }

  @override
  void deinitializePlayer() {
    // No-op: No deinitialization needed
  }

  @override
  void setVoiceSpeed(double voiceSpeed) {
    _voiceSpeed = voiceSpeed;
    _audioPlayer.setSpeed(_voiceSpeed);
  }

  @override
  void updateVoice(String voice) {
    _voice = voice;
  }

  @override
  void dispose() {
    try {
      _audioIntensityTimer?.cancel();
      _audioPlayer.dispose();
      _errorController.close();
      _httpClient.close();
    } catch (e) {
      debugPrint('Error during dispose: $e');
    }
  }

  @override
  bool isPlaying() {
    return _isPlayingAudio;
  }

  @override
  bool hasAudioToPlay() {
    return _hasAudioToPlay;
  }

  @override
  void toggleAutoPause() {
    _autoPause = !_autoPause;
    _waitForNext = _autoPause;
  }

  @override
  void repeat() {
    _repeat = true;
  }

  @override
  void next() {
    _waitForNext = false;
  }

  @override
  bool lastAudioToPlay() {
    return _audioBuffer.isEmpty;
  }

  @override
  String getSubtitles() {
    return _currentSubtitles;
  }

  @override
  double getCurrentIntensity() {
    // TODO: Replace with actual intensity calculation based on audio data
    if (_currentIntensity == minIntensity) return minIntensity;
    _currentIntensity += 2.0 * (Random().nextDouble() - 0.5);
    _currentIntensity = _currentIntensity.clamp(2.0, 8.0);
    return _currentIntensity;
  }

  @override
  Future<void> playTextToSpeech(String text) async {
    if (text.trim().isEmpty) {
      debugPrint("Empty text provided. Ignoring.");
      return;
    }
    _queue.add(text);
    _processQueue(maxCharacters: _maxCharacters);
  }

  @override
  Future<void> stop() async {
    _isPlayingAudio = false;
    _audioIntensityTimer?.cancel();
    await _audioPlayer.stop();
    _audioBuffer.clear();
    _textBuffer.clear();
    _queue.clear();
    _hasAudioToPlay = false;
    _currentSubtitles = "";
    _waitForNext = false;
    _repeat = false;
    _autoPause = false;
  }

  void _addSentenceWithPauses(String text) async {
    try {
      text = text.replaceAll(_endMarker, "").trim();
      List<String> chunks = text.split(_pauseMarker);
      for (String chunk in chunks) {
        if (chunk.isNotEmpty) {
          _audioBuffer.add(_synthesizeAndBuffer(chunk));
          _textBuffer.add(chunk); // Add the same subtitle for each chunk
        }
        _audioBuffer.add(Future.value(null)); // null indicates a pause
        _textBuffer.add(" "); // Simple space to represent pause in subtitles
      }
      // Remove the last pause if unnecessary
      if (chunks.isNotEmpty) {
        _audioBuffer.removeLast();
        _textBuffer.removeLast();
      }
    } catch (e) {
      _handleError(Exception('Error adding sentences with pauses: $e'));
    }
  }

  void _processQueue({required int maxCharacters}) async {
    if (_audioBuffer.length > 1) return;

    while (_queue.isNotEmpty && _audioBuffer.length < 2) {
      try {
        int currentLength = 0;
        List<String> segmentsToPlay = [];

        // Inner loop to collect segments within the character limit
        while (_queue.isNotEmpty && currentLength <= maxCharacters) {
          String segment = _queue.removeFirst();
          segmentsToPlay.add(segment);
          currentLength += segment.length;
        }

        // Concatenate and process the collected segments
        String concatenatedText = segmentsToPlay.join(' ').trim();

        if (concatenatedText.length >= 5) {
          _addSentenceWithPauses(concatenatedText);
        } else {
          debugPrint(
              "Discarded text segment with less than 5 characters after trimming.");
        }

        // Safety check to avoid infinite loop
        if (_queue.isEmpty) {
          break;
        }
      } catch (e) {
        _handleError(Exception('Error processing queue: $e'));
      }
    }

    if (!_hasAudioToPlay) {
      _playBufferedSegments();
    }
  }

  Future<Uint8List?> _synthesizeAndBuffer(String text) async {
    try {
      debugPrint("_synthesizeAndBuffer(String text): $text");
      final segmentBytes = await _synthesizeAudio(text);
      return segmentBytes;
    } catch (e) {
      _handleError(Exception('Error synthesizing and buffering: $e'));
      return null; // Return null to indicate failure
    }
  }

  Future<Uint8List?> _synthesizeAudio(String text) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(Config.openaiTtsUrl),
        headers: {
          'Authorization': 'Bearer ${Config.openaiApiKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "tts-1",
          "input": text,
          "voice": _voice,
          "response_format": "aac" // Ensure this matches MyCustomSource
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
            'Failed to synthesize audio for text "$text". Status code: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(Exception('Error synthesizing audio: $e'));
      return null;
    }
  }

  Future<void> _playBufferedSegments() async {
    _hasAudioToPlay = true;
    if (_isPlayingAudio) return; // Prevent multiple simultaneous playback
    _isPlayingAudio = true;
    bool isFirstSentence = true;

    while (_audioBuffer.isNotEmpty) {
      if (_audioBuffer.isEmpty) {
        _hasAudioToPlay = false;
        _isPlayingAudio = false;
        _handleError(Exception('No audio segments available to play.'));
        return;
      }

      final segmentBytesFuture = _audioBuffer.removeFirst();
      final segmentBytes = await segmentBytesFuture;
      String currentSentence = _textBuffer.removeFirst();

      if (segmentBytes != null && segmentBytes.isNotEmpty) {
        try {
          // Apply the delay only if it's not the first sentence
          if (!isFirstSentence) {
            debugPrint(
                'Pausing for ${_pauseBetweenSentences.inMilliseconds}ms between sentences');
            _currentIntensity = minIntensity;
            await Future.delayed(_pauseBetweenSentences);
          }

          debugPrint("Playing sentence: $currentSentence");

          currentSentence = currentSentence
              .replaceAll('\n', ' ')
              .replaceAll('\r', ' ')
              .trim();

          if (currentSentence.length > 8) {
            _currentSubtitles = currentSentence;
          }

          // Set up the audio source
          await _audioPlayer.setAudioSource(
              MyCustomSource(segmentBytes, contentType: 'audio/aac'));
          _currentIntensity = _defaultSpeakingIntensity;

          // Play the audio
          await _audioPlayer.play();
          // Wait until the audio has finished playing
          await _audioPlayer.playerStateStream.firstWhere(
              (state) => state.processingState == ProcessingState.completed);

          _currentIntensity = minIntensity;

          if (_autoPause) {
            _isPlayingAudio = false;
            _waitForNext = true;
            while (_waitForNext) {
              await Future.delayed(const Duration(milliseconds: 100));

              if (_repeat) {
                _isPlayingAudio = true;
                _waitForNext = false;
                _repeat = false;

                // Replay the current segment
                await _audioPlayer.setAudioSource(
                    MyCustomSource(segmentBytes, contentType: 'audio/aac'));
                await _audioPlayer.play();

                await _audioPlayer.playerStateStream.firstWhere((state) =>
                    state.processingState == ProcessingState.completed);
              }
            }
          }
        } catch (e) {
          _handleError(Exception('Error playing audio: $e'));
        }
      } else {
        // Handle pause
        if (!_autoPause) {
          debugPrint("Pausing for ${_pauseBetweenPauses.inMilliseconds}ms");
          _currentIntensity = minIntensity;
          await Future.delayed(_pauseBetweenPauses);
        }
      }
      isFirstSentence = false;
      if (_audioBuffer.length <= 2) {
        _processQueue(maxCharacters: _maxCharacters);
      }
    }

    _hasAudioToPlay = false;
    _isPlayingAudio = false;
  }

  // Centralized error handling
  void _handleError(Exception e) {
    debugPrint('Error in TextToSpeechOpenAI: $e');
    stop(); // Stopping all operations before adding the error
    if (!_errorController.isClosed) {
      _errorController.add(e);
    }
  }
}

// Feed your own stream of bytes into the player
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  final String contentType;

  MyCustomSource(this.bytes, {this.contentType = 'audio/aac'});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: contentType, // Adjust based on response_format
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TTS Test'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final tts = TextToSpeechOpenAI("echo");
              tts.errorStream.listen((error) {
                // Handle errors (e.g., show a dialog)
                debugPrint('TTS Error: $error');
              });
              await tts.playTextToSpeech("Hello, I am Whisper");

              // Wait for a short time to allow the TTS process to complete
              await Future.delayed(const Duration(seconds: 10));

              // Dispose the TTS instance if needed
              tts.dispose();
            },
            child: const Text('Play TTS'),
          ),
        ),
      ),
    );
  }
}
