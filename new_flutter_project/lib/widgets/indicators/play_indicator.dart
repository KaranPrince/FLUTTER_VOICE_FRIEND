// custom_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_voice_friend/services/animation_controller_service.dart';

class PlayIndicatorWidget extends StatelessWidget {
  final AnimationControllerService animationControllerService;
  final bool isListening;
  final String title;
  final Color textColor;
  final VoidCallback onPress;

  const PlayIndicatorWidget({
    super.key,
    required this.animationControllerService,
    required this.isListening,
    required this.title,
    required this.textColor,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: animationControllerService.pulseAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.25),
                ),
              ),
            ),
            ScaleTransition(
              scale: animationControllerService.animation,
              child: GestureDetector(
                onTap: () {
                  animationControllerService.buttonAnimationController
                      .reverse();
                  animationControllerService.listeningAnimationController
                      .reverse();
                  animationControllerService.animationController.reverse();

                  Future.delayed(const Duration(milliseconds: 500), () {
                    animationControllerService.animationController.stop();
                    animationControllerService.animationController.reset();

                    if (isListening) {
                      // Do something if needed
                    }
                  });
                  onPress();
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        spreadRadius: 10,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 80.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // Space between button and text
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.imFellDoublePica(
            textStyle: TextStyle(
              fontSize: 32,
              color: textColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
