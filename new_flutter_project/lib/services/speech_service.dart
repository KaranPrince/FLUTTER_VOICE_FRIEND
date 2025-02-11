// lib/services/speech_service.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/utils/audio_utils.dart';

class SpeechService {
  Deepgram? _deepgram;
  DeepgramLiveTranscriber? _transcriber;
  bool _transcriberStarted = false;
  StreamSubscription<List<int>>? _micSubscription;
  late stt.SpeechToText _speechToText;
  bool _speechAvailable = false;
  bool _deepgramHasBeenInitialized = false;
  late Stream<Uint8List> micStream;

  final AudioRecorder _audioRecorder = AudioRecorder();

  // StreamController to emit errors
  final StreamController<Exception> errorController =
      StreamController<Exception>.broadcast();

// Expose the error stream
  Stream<Exception> get errorStream => errorController.stream;

  late void Function(double) onSoundLevelChange;
  late void Function(String) onTranscription;

  SpeechService();

  Future<void> initialize(String selectedSpeechToTextMethod) async {
    // Test a recording a stop it right away
    if (selectedSpeechToTextMethod == Config.deepgramStt) {
      await _initializeDeepgram(handleError: false);
    } else if (selectedSpeechToTextMethod == Config.onDeviceStt) {
      await _initializeOnDeviceSpeechRecognition();
    } else {
      throw Exception('Initialize: Not recognized selectedSpeechToTextMethod');
    }
  }

  Future<void> updateSpeechToTextMethod(
      String selectedSpeechToTextMethod) async {
    if (selectedSpeechToTextMethod == Config.deepgramStt) {
      debugPrint("Initializing Deepgram STT");
      if (!_deepgramHasBeenInitialized) {
        await _initializeDeepgram();
      }
    } else if (selectedSpeechToTextMethod == Config.onDeviceStt) {
      debugPrint("Initializing OnDevice STT");
      await _initializeOnDeviceSpeechRecognition();
    } else {
      throw Exception('Initialize: Not recognized selectedSpeechToTextMethod');
    }
  }

  Future<void> _initializeDeepgram({handleError = true}) async {
    Map<String, dynamic> params = {
      'model': 'nova-2-general',
      'filler_words': false,
      'punctuation': true,
    };

    try {
      _deepgram = Deepgram(Config.deepgramApiKey, baseQueryParams: params);
      final isValid = await _deepgram!.isApiKeyValid();
      debugPrint('Deepgram API key is valid: $isValid');
      _deepgramHasBeenInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Deepgram: $e');
      if (handleError) {
        _handleError(Exception('Failed to initialize Deepgram: $e'));
      } else {
        rethrow;
      }
    }
  }

  Future<void> _initializeAudioRecorder() async {
    final startTime = DateTime.now();
    debugPrint('Initializing Audio Recorder (Start Stream) at $startTime');

    micStream = await _audioRecorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    debugPrint('End initialization Audio Recorder (Start Stream) at $endTime');
    debugPrint('Audio Recorder initialized in ${duration.inMilliseconds} ms');
  }

  Future<void> _initializeOnDeviceSpeechRecognition() async {
    _speechToText = stt.SpeechToText();
    try {
      _speechAvailable = await _speechToText.initialize();
      if (!_speechAvailable) {
        debugPrint('On-device speech recognition is not available');
        _handleError(
            Exception('On-device speech recognition is not available'));
      }
    } catch (e) {
      debugPrint('Error initializing on-device speech recognition: $e');
      _handleError(
          Exception('Failed to initialize on-device speech recognition: $e'));
    }
  }

  Future<void> startListening(
      String selectedSpeechToTextMethod, String selectedLanguage) async {
    if (selectedSpeechToTextMethod == Config.deepgramStt) {
      await _startDeepgramListening(selectedLanguage);
    } else if (selectedSpeechToTextMethod == Config.onDeviceStt) {
      await _startOnDeviceListening(selectedLanguage);
    } else {
      throw Exception(
          'Start Listening: Not recognized selectedSpeechToTextMethod');
    }
  }

  Future<void> stopListening(String selectedSpeechToTextMethod) async {
    if (selectedSpeechToTextMethod == Config.deepgramStt) {
      await _stopDeepgramListening();
    } else if (selectedSpeechToTextMethod == Config.onDeviceStt) {
      await _stopOnDeviceListening();
    } else {
      throw Exception(
          'Stop Listening: Not recognized selectedSpeechToTextMethod');
    }
  }

  Future<void> _startOnDeviceListening(String selectedLanguage) async {
    if (!_speechAvailable) {
      debugPrint("Speech is not available");
      return;
    }

    final options = stt.SpeechListenOptions(
        onDevice: false,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true);

    try {
      _speechToText.listen(
        localeId: Config.languageCodeMap[selectedLanguage],
        onSoundLevelChange: soundLevelListener,
        listenOptions: options,
        onResult: (result) {
          onTranscription(result.recognizedWords);
        },
      );
    } catch (e) {
      debugPrint("Error starting on-device listening: $e");
      _handleError(Exception('Failed to start on-device listening: $e'));
    }
  }

  void soundLevelListener(double level) {
    onSoundLevelChange(
        AudioUtils.normalizeOnDeviceLevel(level, minDb: -45, maxDb: -10));
  }

  Future<void> _stopOnDeviceListening() async {
    try {
      if (_speechToText.isListening) await _speechToText.stop();
    } catch (e) {
      debugPrint("Error stopping on-device listening: $e");
      _handleError(Exception('Failed to stop on-device listening: $e'));
    }
  }

  Future<void> _startDeepgramListening(String selectedLanguage) async {
    if (_deepgram == null) await _initializeDeepgram();

    await _initializeAudioRecorder();
    // Listen to the micStream for audio level
    _micSubscription = micStream.listen(
      (data) {
        Uint8List byteData = Uint8List.fromList(data);
        double normalizedLevel = AudioUtils.normalizeAudioRecorderLevel(
          byteData,
          reference: 32768.0, // Adjust if necessary
        );
        onSoundLevelChange(normalizedLevel);
      },
      onError: (error) {
        debugPrint("Mic stream error: $error");
        if (error is Exception) {
          _handleError(error);
        } else {
          _handleError(Exception('An unexpected error occurred'));
        }
      },
    );

    final streamParams = {
      'detect_language': false,
      'language': selectedLanguage.toLowerCase(),
      'encoding': 'linear16',
      'sample_rate': 16000,
    };

    try {
      _transcriber = _deepgram!
          .createLiveTranscriber(micStream, queryParams: streamParams);

      await _transcriber!.start();
      _transcriberStarted = true;

      debugPrint("Starting the listener on Deepgram");
      String transcription = "";
      _transcriber!.stream.listen(
        (res) {
          transcription += " ${res.transcript}";
          onTranscription(transcription);
        },
        onError: (error) {
          debugPrint("Transcriber stream error: $error");
          _handleError(Exception('Transcriber stream error: $error'));
        },
        onDone: () {
          debugPrint("Deepgram transcription done");
        },
      );
    } catch (error) {
      debugPrint("Error during transcriber creation: $error");
      if (error is Exception) {
        _handleError(error);
      } else {
        _handleError(Exception('An unexpected error occurred'));
      }
    }
  }

  Future<void> _stopDeepgramListening() async {
    try {
      await _audioRecorder.stop();
      await _micSubscription?.cancel();
      _micSubscription = null;
      if (_transcriberStarted) {
        await _transcriber!.close();
        _transcriberStarted = false;
      }
    } catch (e) {
      debugPrint("Error stopping Deepgram listening: $e");
      _handleError(Exception('Failed to stop Deepgram listening: $e'));
    }
  }

  void cancelOperations(selectedSpeechToTextMethod) {
    stopListening(selectedSpeechToTextMethod);
  }

  void dispose() {
    _stopDeepgramListening();
    _speechToText.stop();
    errorController.close();
  }

  // Centralized error handling
  void _handleError(Exception e) {
    if (!errorController.isClosed) {
      errorController.add(e);
    }
    debugPrint('Error in SpeechService: $e');
  }
}
