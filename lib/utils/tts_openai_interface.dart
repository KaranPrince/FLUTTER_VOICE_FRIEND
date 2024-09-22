abstract class TextToSpeechOpenAI {
  Stream<Exception> get errorStream;
  bool isPlaying();
  bool hasAudioToPlay();
  double getCurrentIntensity();
  String getSubtitles();
  void stop();
  void setVoiceSpeed(double voiceSpeed);
  void updateVoice(String voice);
  Future<void> playTextToSpeech(String text);
  void dispose();
  bool lastAudioToPlay();
  void repeat();
  void next();
  void toggleAutoPause();
  // Function to initialize the player
  Future<void> initializePlayer();
  void deinitializePlayer();
}
