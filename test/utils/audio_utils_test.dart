import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/utils/audio_utils.dart';

void main() {
  group('AudioUtils Tests', () {
    test('Should calculate RMS correctly', () {
      final data = Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]); // Silence
      final rms = AudioUtils.calculateRMS(data);

      expect(rms, 0);
    });

    test('Should convert RMS to dB correctly', () {
      final db = AudioUtils.rmsToDb(0);

      expect(db, -60.0);
    });

    test('Should normalize dB value correctly', () {
      final normalized = AudioUtils.normalizeDb(-30.0);

      expect(normalized, 0.25);
    });

    // Add tests for getScale and getOutputScale methods
  });
}
