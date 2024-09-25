// lib/services/audio_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/utils/tts_openai_interface.dart';
import 'package:flutter_voice_friend/utils/tts_openai_justaudio.dart'
    as tts_just_audio;
import 'package:flutter_voice_friend/utils/tts_openai_soloud.dart'
    as tts_so_loud;
import 'package:flutter_voice_friend/constants.dart';

class AudioService {
  TextToSpeechOpenAI tts = tts_just_audio.TextToSpeechOpenAI(
      Config.defaultVoice); // = TextToSpeechOpenAI(Config.defaultVoice);

  // StreamController to emit intensity values
  final StreamController<double> _intensityController =
      StreamController<double>.broadcast();

  // StreamController to emit errors
  final StreamController<Exception> _errorController =
      StreamController<Exception>.broadcast();

  Timer? _intensityTimer;
  double _currentIntensity = PlayWidgetConstant.intensityMin;

  // Initialize the TTS system based on config flag
  void initTTS(String audioBackend) {
    tts.dispose();
    if (audioBackend == Config.soloudBackend) {
      debugPrint("Initialize Audio Service with SoLoud AudioBackend");
      tts = tts_so_loud.TextToSpeechOpenAI(Config.defaultVoice);
    } else if (audioBackend == Config.justAudioBackend) {
      debugPrint("Initialize Audio Service with just_audio AudioBackend");
      tts = tts_just_audio.TextToSpeechOpenAI(Config.defaultVoice);
    } else {
      throw Exception("Unsupported Audio Backend");
    }
    initPlayer();
    initStreams();
  }

  void initStreams() {
    _startIntensityTimer();
    _listenToTTSErrors();
  }

  AudioService();

  // Expose the intensity stream
  Stream<double> get intensityStream => _intensityController.stream;

  // Expose the error stream
  Stream<Exception> get errorStream => _errorController.stream;

  // Listen to TextToSpeechOpenAI's error stream and re-emit
  void _listenToTTSErrors() {
    tts.errorStream.listen((Exception error) {
      _errorController.add(error);
    });
  }

  // Start a periodic timer to calculate and emit intensity
  void _startIntensityTimer() {
    _intensityTimer?.cancel();
    _intensityTimer =
        Timer.periodic(PlayWidgetConstant.intensityUpdateInterval, (timer) {
      _updateIntensity();
    });
  }

  // Calculate new intensity based on audio level and emit it
  void _updateIntensity() {
    double audioLevel = getCurrentIntensity();
    double intensity = _calculateNewIntensity(audioLevel);
    _intensityController.add(intensity);
  }

  double _calculateNewIntensity(double audioLevel) {
    double intensity = audioLevel / PlayWidgetConstant.intensityDivisor;

    //if (intensity < SiriWaveWidgetConstant.intensityThreshold) {
    //_currentIntensity -= SiriWaveWidgetConstant.intensityDecrement;
    _currentIntensity = intensity.clamp(
        PlayWidgetConstant.intensityMin, PlayWidgetConstant.intensityMax);
    //_currentIntensity = max(intensity, SiriWaveWidgetConstant.intensityMin);
    //_currentIntensity = min(intensity, SiriWaveWidgetConstant.intensityMax);
    //} else {
    //_currentIntensity += SiriWaveWidgetConstant.intensityIncrement;
    //_currentIntensity = min(intensity, SiriWaveWidgetConstant.intensityMax);
    //}

    return _currentIntensity;
  }

  void deinitPlayer() {
    tts.deinitializePlayer();
  }

  Future<void> initPlayer() async {
    debugPrint("Audio Service initPlayer called");
    await tts.initializePlayer();
  }

  void initialize(
      String audioBackend, String selectedVoice, double voiceSpeed) {
    initTTS(audioBackend);
    tts.updateVoice(selectedVoice);
    tts.setVoiceSpeed(voiceSpeed);
  }

  Future<void> playTextToSpeech(String text) async {
    try {
      await tts.playTextToSpeech(text);
    } catch (e) {
      // Handle any unexpected errors that might not be caught inside TTS
      _handleError(Exception('Unexpected error in playTextToSpeech: $e'));
    }
  }

  void stop() {
    tts.stop();
  }

  Future<void> dispose() async {
    await _intensityController.close();
    await _errorController.close();
    _intensityTimer?.cancel();
    tts.dispose();
  }

  bool isPlaying() {
    return tts.isPlaying();
  }

  bool hasAudioToPlay() {
    return tts.hasAudioToPlay();
  }

  double getCurrentIntensity() {
    return tts.getCurrentIntensity();
  }

  String getSubtitles() {
    return tts.getSubtitles();
  }

  void repeat() {
    tts.repeat();
  }

  void next() {
    tts.next();
  }

  void setVoiceSpeed(double voiceSpeed) {
    tts.setVoiceSpeed(voiceSpeed);
  }

  void updateVoice(String selectedVoice) {
    tts.updateVoice(selectedVoice);
  }

  bool lastAudioToPlay() {
    return tts.lastAudioToPlay();
  }

  void toggleAutoPause() {
    tts.toggleAutoPause();
  }

  void cancelOperations() {
    stop();
  }

  // Centralized error handling
  void _handleError(Exception e) {
    if (!_errorController.isClosed) {
      _errorController.add(e);
    }
    debugPrint('Error in AudioService: $e');
  }
}
