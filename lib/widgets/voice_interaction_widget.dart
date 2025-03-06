import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceInteractionWidget extends StatefulWidget {
  const VoiceInteractionWidget({super.key}); // Updated key parameter

  @override
  _VoiceInteractionWidgetState createState() => _VoiceInteractionWidgetState();
}

class _VoiceInteractionWidgetState extends State<VoiceInteractionWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  FlutterTts flutterTts = FlutterTts();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    setState(() {
      _isLoading = true;
    });
    if (!_isListening) {
      bool available = await _speech.initialize(); // Removed print statements
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0.8) {
              _speak(_text);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Voice Friend',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          _isLoading
              ? const CircularProgressIndicator()
              : Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              _text,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          ElevatedButton(
            onPressed: _listen,
            child: Text(_isListening ? 'Stop' : 'Listen'),
          ),
        ],
      ),
    );
  }
}