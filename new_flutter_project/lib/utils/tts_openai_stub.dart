import 'dart:async';

Future<void> initializePlayer() async {
  // No-op: No initialization needed
}

void deinitializePlayer() {
  // No-op: No deinitialization needed
}

class TextToSpeechOpenAI {
  // StreamController to emit errors
  final StreamController<Exception> _errorController =
      StreamController<Exception>.broadcast();

  // Expose the error stream
  Stream<Exception> get errorStream => _errorController.stream;

  TextToSpeechOpenAI(String voice) {
    // No-op: No initialization needed
  }

  void updateVoice(String voice) {
    // No-op: No update needed
  }

  void setVoiceSpeed(double voiceSpeed) {
    // No-op: No update needed
  }

  void dispose() {
    // No-op: No disposal needed
  }

  bool isPlaying() {
    // No-op: Always return false, no audio is playing
    return false;
  }

  bool hasAudioToPlay() {
    // No-op: Always return false, no audio to play
    return false;
  }

  bool lastAudioToPlay() {
    // No-op: Always return false, no audio to play
    return false;
  }

  String getSubtitles() {
    // No-op: Return an empty string, no subtitles available
    return "";
  }

  void stop() {
    // No-op: No stopping needed
  }

  void toggleAutoPause() {
    // No-op: No toggle needed
  }

  void next() {
    // No-op: No next operation needed
  }

  void repeat() {
    // No-op: No repeat operation needed
  }

  double getCurrentIntensity() {
    // No-op: Always return 0.0, no intensity to report
    return 0.0;
  }

  Future<void> playTextToSpeech(String text) async {
    // No-op: No text-to-speech to play
  }
}
