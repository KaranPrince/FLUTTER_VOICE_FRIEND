// lib/utils/tts_openai_soloud.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:collection';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:flutter_voice_friend/utils/tts_openai_interface.dart'
    as tts_interface;

// Initialize SoLoud instance
final soloud = SoLoud.instance;

// Function to extract asset
Future<String> extractAsset(String assetName) async {
  // Load the asset as bytes from the asset bundle
  final byteData = await rootBundle.load("assets/sounds/$assetName");

  // Get a temporary directory to store the file
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/$assetName';

  // Write the bytes to a file
  final file = File(filePath);
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  // Return the file path
  return filePath;
}

class TextToSpeechOpenAI implements tts_interface.TextToSpeechOpenAI {
  final soloud = SoLoud.instance;
  final Queue<String> _queue = Queue<String>();
  bool _hasAudioToPlay = false;
  bool _isPlayingAudio = false;
  ffi.Pointer<ffi.Pointer<ffi.Float>> playerData = ffi.nullptr;

  final bool debug = true;

  final Queue<Future<String>> _audioBuffer = Queue<Future<String>>();
  final Queue<String> _textBuffer = Queue<String>();

  String _currentSubtitles = "";

  double _currentIntensity = 0;

  final int _maxCharacters = 200;

  double _voiceSpeed = 1.0;

  bool _autoPause = false;
  bool _waitForNext = false;
  bool _repeat = false;
  String _voice;
  final Uuid _uuid = const Uuid();
  late Directory _tempDirectoryForAudioFiles;
  Timer? _audioIntensityTimer;

  int _timePlayedInMs = 0;

  // StreamController to emit errors
  final StreamController<Exception> _errorController =
      StreamController<Exception>.broadcast();

  // Expose the error stream
  @override
  Stream<Exception> get errorStream => _errorController.stream;

  TextToSpeechOpenAI(this._voice) {
    // Initialize the player
    playerData = calloc();
    _initializeTempDirectory();
  }

  // Function to initialize the player
  @override
  Future<void> initializePlayer() async {
    debugPrint("initialize Soloud library");
    await soloud.init(
        automaticCleanup: true, timeout: const Duration(seconds: 20));
    soloud.setVisualizationEnabled(true);
    soloud.setGlobalVolume(1);
    soloud.setMaxActiveVoiceCount(32);
  }

// Function to deinitialize the player
  @override
  void deinitializePlayer() {
    if (soloud.isInitialized) {
      soloud.deinit();
    }
  }

  Future<void> reinitPlayer() async {
    debugPrint("Calling reinit Player");
    deinitializePlayer();
    await initializePlayer();
  }

  /// Initialize the temporary subdirectory
  Future<void> _initializeTempDirectory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      _tempDirectoryForAudioFiles = Directory('${tempDir.path}/tts_audio');

      // If the subdirectory exists, clear it
      await _cleanupTempDirectory();

      // Recreate the subdirectory
      await _tempDirectoryForAudioFiles.create();
    } catch (e) {
      _handleError(Exception('Failed to initialize temp directory: $e'));
    }
  }

  /// Clear the subdirectory when deinitializing the player
  Future<void> _cleanupTempDirectory() async {
    try {
      if (await _tempDirectoryForAudioFiles.exists()) {
        await _tempDirectoryForAudioFiles.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Failed to clean up temp directory: $e');
    }
  }

  @override
  void setVoiceSpeed(double voiceSpeed) {
    _voiceSpeed = voiceSpeed;
  }

  void _startAudioDataFetch() {
    _audioIntensityTimer?.cancel(); // Cancel any existing timer
    _audioIntensityTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPlayingAudio) {
        timer.cancel();
        return;
      }
      soloud.getAudioTexture2D(playerData);

      final ffi.Pointer<ffi.Float> audioData = playerData.value;
      double a = 0;
      for (var i = 0; i <= 10; i++) {
        a += audioData[i];
      }
      _currentIntensity = a;
    });
  }

  @override
  double getCurrentIntensity() {
    return _currentIntensity;
  }

  @override
  void updateVoice(String voice) {
    _voice = voice;
  }

  @override
  void dispose() {
    try {
      soloud.deinit();
      if (playerData != ffi.nullptr) {
        calloc.free(playerData);
        playerData = ffi.nullptr;
      }
      _cleanupTempDirectory();
      _errorController.close();
    } catch (e) {
      // Handle any exceptions during dispose
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
  void stop() async {
    _isPlayingAudio = false;
    _audioIntensityTimer?.cancel();
    if (soloud.isInitialized) await soloud.disposeAllSources();
    _audioBuffer.clear();
    _textBuffer.clear();
    _queue.clear();
    _hasAudioToPlay = false;
    _currentSubtitles = "";
    _waitForNext = false;
    _repeat = false;
    _autoPause = false;
  }

  bool isAutoPauseActivated() {
    return _autoPause;
  }

  @override
  Future<void> playTextToSpeech(String text) async {
    _queue.add(text);
    _processQueue(maxCharacters: _maxCharacters);
  }

  void _addSentenceWithPauses(String text) async {
    try {
      // Split the text into chunks separated by "[pause]"
      text = text.replaceAll("[END]", ""); // Clean text for subtitle

      List<String> chunks = text.split("[pause]");

      var numberOfConsecutivePause = 0;
      for (String chunk in chunks) {
        if (chunk.trim().isNotEmpty) {
          numberOfConsecutivePause = 0;
          // Add synthesized audio for the non-empty chunk
          _audioBuffer.add(_synthesizeAndBuffer(chunk));
          _textBuffer.add(chunk); // Add the same subtitle for each chunk
        }
        numberOfConsecutivePause++;

        _audioBuffer.add(Future.value("pause"));
        _textBuffer.add(" . " *
            numberOfConsecutivePause); // Ensure subtitle is consistent across pauses
      }
      // Remove the extra pause added at the end of the chunks
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
          if (debug) {
            debugPrint(
                "${concatenatedText.length} characters: $concatenatedText");
          }
          _addSentenceWithPauses(concatenatedText);
        } else {
          if (debug) {
            debugPrint(
                "Discarded text segment with less than 5 characters after trimming.");
          }
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

  Future<String> _synthesizeAndBuffer(String text) async {
    if (debug) {
      debugPrint("TTS buffering: Synthesizing and buffering text: $text");
    }
    try {
      final segmentPath = await _synthesizeAudio(text);
      return segmentPath;
    } catch (e) {
      _handleError(Exception('Error synthesizing and buffering: $e'));
      return ''; // Return empty string to indicate failure
    }
  }

  @override
  String getSubtitles() {
    return _currentSubtitles;
  }

  Future<void> _playBufferedSegments() async {
    _hasAudioToPlay = true;
    if (!soloud.isInitialized) {
      debugPrint("soLoud was not initialized, initializing now...");
      try {
        await initializePlayer();
      } catch (e) {
        _handleError(Exception('Failed to initialize SoLoud: $e'));
        return;
      }
    }

    bool isFirstSentence = true;

    while (_audioBuffer.isNotEmpty) {
      if (_audioBuffer.isEmpty) {
        _hasAudioToPlay = false;
        _isPlayingAudio = false;
        _handleError(Exception('No audio segments available to play.'));
        return;
      }
      final segmentPathFuture = _audioBuffer.removeFirst();
      final segmentPath = await segmentPathFuture;

      String currentSentence = _textBuffer.removeFirst();

      if (segmentPath.isNotEmpty) {
        _isPlayingAudio = true;

        // Apply the delay only if it's not the first sentence
        if (!isFirstSentence) {
          if (debug) {
            debugPrint('Pausing for 300ms between sentences');
          }
          await Future.delayed(const Duration(milliseconds: 300));
        }

        if (segmentPath == "pause") {
          if (!_autoPause) {
            if (debug) {
              debugPrint("[PAUSE]: Pausing for 1.5 seconds");
            }
            await Future.delayed(const Duration(milliseconds: 1500));
          }
        } else {
          try {
            if (debug) {
              debugPrint("PLAYING BUFFER PATH: $segmentPath");
              debugPrint("  And sentence: $currentSentence");
            }

            // Dispose all previous sources to prevent overlap
            await soloud.disposeAllSources();

            // Load and Play the audio file
            final source = await soloud.loadFile(segmentPath);
            final handle = await soloud.play(source);
            soloud.setRelativePlaySpeed(handle, _voiceSpeed);

            _startAudioDataFetch();

            currentSentence = currentSentence
                .replaceAll('\n', ' ')
                .replaceAll('\r', ' ')
                .trim();

            if (currentSentence.length > 8) {
              _currentSubtitles = currentSentence;
            }

            _timePlayedInMs = 0;

            // Wait until the audio finishes playing
            while (soloud.getIsValidVoiceHandle(handle)) {
              _timePlayedInMs += 100;
              await Future.delayed(const Duration(milliseconds: 100));
              if (_timePlayedInMs > 20000 && _autoPause) {
                debugPrint(_timePlayedInMs.toString());
                break;
              }
            }

            await soloud.stop(handle);
            await soloud.disposeSource(source);

            if (_autoPause) {
              _isPlayingAudio = false;
              _waitForNext = true;
              while (_waitForNext) {
                await Future.delayed(const Duration(milliseconds: 100));

                if (_repeat) {
                  _isPlayingAudio = true;
                  _waitForNext = false;
                  await soloud.disposeAllSources();
                  final source = await soloud.loadFile(segmentPath);
                  final handle = await soloud.play(source);
                  soloud.setRelativePlaySpeed(handle, _voiceSpeed);
                  _startAudioDataFetch();

                  _timePlayedInMs = 0;

                  while (soloud.getIsValidVoiceHandle(handle)) {
                    _timePlayedInMs += 100;
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (_timePlayedInMs > 20000) break;
                  }

                  await soloud.stop(handle);
                  await soloud.disposeSource(source);
                  _repeat = false;
                  _isPlayingAudio = false;
                  _waitForNext = true;
                }
              }
            }
          } catch (e) {
            _handleError(Exception('Error playing audio: $e'));
          } finally {
            // Optionally delete the temporary file after playing it
            // Uncomment the following block if you want to delete the file
            /*
            if (segmentPath.isNotEmpty) {
              try {
                final file = File(segmentPath);
                if (await file.exists()) {
                  await file.delete();
                }
              } catch (e) {
                debugPrint('Error deleting temporary audio file: $e');
              }
            }
            */
          }
        }
      }

      isFirstSentence = false;
      if (_audioBuffer.length <= 2) {
        _processQueue(maxCharacters: _maxCharacters);
      }
    }
    //_currentSubtitles = "";
    _hasAudioToPlay = false;
    _isPlayingAudio = false;
  }

  Future<String> _synthesizeAudio(String text) async {
    try {
      final response = await http.post(
        Uri.parse(Config.openaiTtsUrl),
        headers: {
          'Authorization': 'Bearer ${Config.openaiApiKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "tts-1",
          "input": text,
          "voice": _voice,
          "response_format": "wav"
        }),
      );

      if (response.statusCode == 200) {
        final uniqueFilename = _uuid.v4();
        final filePath =
            path.join(_tempDirectoryForAudioFiles.path, '$uniqueFilename.wav');

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      } else {
        throw Exception(
            'Failed to synthesize audio. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(Exception('Error synthesizing audio: $e'));
      throw Exception('Failed to synthesize audio');
    }
  }

  // Centralized error handling
  void _handleError(Exception e) {
    debugPrint('Error in TextToSpeechOpenAI: $e');
    stop(); // Stopping all operation before adding the error
    if (!_errorController.isClosed) {
      _errorController.add(e);
    }
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
              await SoLoud.instance.init(automaticCleanup: true);
              SoLoud.instance.setVisualizationEnabled(true);
              SoLoud.instance.setGlobalVolume(1);
              SoLoud.instance.setMaxActiveVoiceCount(32);

              final tts = TextToSpeechOpenAI("echo");
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
