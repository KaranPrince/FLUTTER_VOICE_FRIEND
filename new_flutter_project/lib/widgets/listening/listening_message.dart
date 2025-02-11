// listening_message.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListeningMessage extends StatelessWidget {
  final bool listeningMode;
  final bool firstMessage;
  final bool isListening;
  final String transcription;
  final Color textColor;
  final double audioLevel;

  const ListeningMessage({
    super.key,
    required this.listeningMode,
    required this.firstMessage,
    required this.isListening,
    required this.transcription,
    required this.textColor,
    required this.audioLevel,
  });

  String _determineMessage() {
    if (listeningMode && !firstMessage && !isListening) {
      return "Tap microphone to talk";
    }
    if (audioLevel == 0.0 &&
        listeningMode &&
        !firstMessage &&
        isListening &&
        transcription.trim().isEmpty) {
      return "Start talking";
    }
    if (audioLevel == 0.0 &&
        listeningMode &&
        !firstMessage &&
        isListening &&
        transcription.trim().isNotEmpty) {
      return "Press ⬜ to send";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    String message = _determineMessage();
    if (message.isEmpty) {
      return Container();
    }
    return Center(
      child: Text(
        message,
        style: GoogleFonts.imFellDoublePica(
          textStyle: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
