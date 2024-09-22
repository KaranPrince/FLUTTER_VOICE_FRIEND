import 'package:flutter/material.dart';

class BottomIconsWhenPlaying extends StatelessWidget {
  final bool isPlaying;
  final bool isPaused;
  final bool remainingLLMResponse;
  final Function onPause;
  final Function onStop;
  final Function onRepeat;
  final Function onNext;
  final Function onResume;
  final bool lastAudioToPlay;

  const BottomIconsWhenPlaying({
    super.key,
    required this.isPlaying,
    required this.isPaused,
    required this.remainingLLMResponse,
    required this.onPause,
    required this.onStop,
    required this.onRepeat,
    required this.onNext,
    required this.onResume,
    required this.lastAudioToPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (isPlaying)
          GestureDetector(
            onTap: () {
              if (isPaused) return;
              onPause();
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPaused
                    ? Colors.grey.withOpacity(0.25)
                    : Colors.yellow.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: isPaused
                        ? Colors.grey.withOpacity(0.15)
                        : Colors.yellow.withOpacity(0.5),
                    spreadRadius: 10,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.pause,
                color: isPaused ? Colors.grey : Colors.white,
                size: 50.0,
              ),
            ),
          ),
        if (isPaused && !isPlaying && !lastAudioToPlay)
          GestureDetector(
            onTap: () {
              if (remainingLLMResponse) return;
              onStop();
            },
            child: Column(
              children: [
                Text(
                  'Stop',
                  style: TextStyle(
                    color: remainingLLMResponse ? Colors.grey : Colors.red,
                    fontSize: 14.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: remainingLLMResponse
                        ? Colors.grey.withOpacity(0.8)
                        : Colors.red.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: remainingLLMResponse
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                        spreadRadius: 10,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ],
            ),
          ),
        if (isPaused && !isPlaying)
          GestureDetector(
            onTap: () {
              onRepeat();
            },
            child: Column(
              children: [
                const Text(
                  'Repeat',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        spreadRadius: 10,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.repeat,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ],
            ),
          ),
        if (isPaused && !isPlaying)
          GestureDetector(
            onTap: () {
              onNext();
            },
            child: Column(
              children: [
                Text(
                  lastAudioToPlay ? 'End' : 'Next',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        spreadRadius: 10,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ],
            ),
          ),
        if (isPaused && !isPlaying && !lastAudioToPlay)
          GestureDetector(
            onTap: () {
              onResume();
            },
            child: Column(
              children: [
                const Text(
                  'Resume',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 14.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.5),
                        spreadRadius: 10,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fast_forward,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
