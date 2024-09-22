import 'package:flutter/material.dart';

class AnimationControllerService {
  late AnimationController animationController;
  late Animation<double> animation;
  late AnimationController buttonAnimationController;
  late Animation<double> buttonAnimation;

  late AnimationController listeningAnimationController;
  late Animation<double> listeningAnimation;

  late AnimationController playingAnimationController;
  late Animation<double> playingAnimation;

  late AnimationController pulseAnimationController;
  late Animation<double> pulseAnimation;

  bool _initialized = false;

  void initialize(TickerProvider vsync) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );

    animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );

    buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: buttonAnimationController, curve: Curves.easeInOut),
    );

    listeningAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );
    listeningAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: listeningAnimationController, curve: Curves.easeInOut),
    );

    playingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );
    playingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: playingAnimationController, curve: Curves.easeInOut),
    );

    pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: vsync,
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
          parent: pulseAnimationController, curve: Curves.easeInOut),
    );
    _initialized = true;
  }

  void dispose() {
    if (_initialized) {
      animationController.dispose();
      buttonAnimationController.dispose();
      pulseAnimationController.dispose();
      listeningAnimationController.dispose();
      playingAnimationController.dispose();
    }
    _initialized = false;
  }
}
