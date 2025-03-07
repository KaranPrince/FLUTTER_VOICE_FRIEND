import 'package:flutter/material.dart';
import 'widgets/voice_interaction_widget.dart'; // Import the new widget

void main() {
  runApp(const MyApp()); // Add const here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Add const and key parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Voice Friend'), // Add const here
        ),
        body: const Center(
          child: VoiceInteractionWidget(), // Use the new widget here and add const
        ),
      ),
    );
  }
}