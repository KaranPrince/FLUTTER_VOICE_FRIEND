import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetryCancelWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const RetryCancelWidget({
    super.key,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "😕 Oops! Whisper had a little hiccup processing your request.",
              textAlign: TextAlign.left,
              style: GoogleFonts.imFellDoublePica(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "🔄 No worries! I can retry sending your command to Whisper and we’ll give it another go.",
              textAlign: TextAlign.left,
              style: GoogleFonts.imFellDoublePica(
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onRetry,
                  child: Text(
                    "Retry 🔄",
                    style: GoogleFonts.imFellDoublePica(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Clickable link style
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onCancel,
                  child: Text(
                    "Cancel ❌",
                    style: GoogleFonts.imFellDoublePica(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // Clickable link style
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
