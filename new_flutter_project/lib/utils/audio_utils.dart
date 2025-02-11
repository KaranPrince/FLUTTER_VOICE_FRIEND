import 'dart:math';
import 'dart:typed_data';

class AudioUtils {
  /// Calculates the Root Mean Square (RMS) of the audio data.
  static double calculateRMS(Uint8List data) {
    int sum = 0;
    int sampleCount = data.length ~/ 2; // 16-bit audio
    for (int i = 0; i < data.length; i += 2) {
      int sample = data[i] | (data[i + 1] << 8);
      if (sample >= 32768) sample -= 65536;
      sum += sample * sample;
    }
    double mean = sum / sampleCount;
    return sqrt(mean);
  }

  /// Converts RMS to decibels (dB).
  static double rmsToDb(double rms, {double reference = 32768.0}) {
    if (rms == 0) return -60.0; // Minimum dB value
    double db = 20 * log(rms / reference) / ln10;
    return db.clamp(-60.0, 60.0); // Clamp to expected dB range
  }

  /// Normalizes a dB value to a range between 0 and 1.
  /// [minDb] and [maxDb] define the expected range of dB values.
  static double normalizeDb(double db,
      {double minDb = -60.0, double maxDb = 60.0}) {
    final ndb = ((db - minDb) / (maxDb - minDb)).clamp(0.0, 1.0);
    return ndb;
  }

  /// Normalizes Deepgram's audio data.
  static double normalizeAudioRecorderLevel(Uint8List data,
      {double reference = 32768.0}) {
    double rms = calculateRMS(data);
    double db = rmsToDb(rms, reference: reference);
    return normalizeDb(db, maxDb: -30);
  }

  /// Normalizes on-device STT dB levels.
  static double normalizeOnDeviceLevel(double db,
      {double minDb = -60.0, double maxDb = 60.0}) {
    return normalizeDb(db, minDb: minDb, maxDb: maxDb);
  }

  static double getScale(double normalizedLevel, double currentScale,
      double minValue, double maxValue) {
    double growSpeed = 0.25;
    double decaySpeed = 0.2;
    // Calculate the target scale based on the normalized audio level
    double targetScale = minValue + (maxValue - minValue) * normalizedLevel;

    // Apply different smoothing speeds for growing and decaying
    double speed = (targetScale > currentScale) ? growSpeed : decaySpeed;

    // Smoothly interpolate towards the target scale
    double smoothScale = currentScale + (targetScale - currentScale) * speed;

    // Clamp the value within the min and max range
    return smoothScale.clamp(minValue, maxValue);
  }

  static double getOutputScale(double normalizedLevel, double currentScale,
      double minValue, double maxValue) {
    double growSpeed = 0.5;
    double decaySpeed = 0.5;
    // Calculate the target scale based on the normalized audio level
    double targetScale = minValue + (maxValue - minValue) * normalizedLevel;

    // Apply different smoothing speeds for growing and decaying
    double speed = (targetScale > currentScale) ? growSpeed : decaySpeed;

    // Smoothly interpolate towards the target scale
    double smoothScale = currentScale + (targetScale - currentScale) * speed;

    // Clamp the value within the min and max range
    return smoothScale.clamp(minValue, maxValue);
  }
}
