import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../../utils/audio_utils.dart';

class ListeningAnimation extends StatefulWidget {
  final double width;
  final double initialScale;
  final double minScale;
  final double maxScale;

  const ListeningAnimation({
    super.key,
    required this.width,
    this.initialScale = 1.0,
    this.minScale = 0.75,
    this.maxScale = 3.0,
  });

  @override
  ListeningAnimationState createState() => ListeningAnimationState();
}

class ListeningAnimationState extends State<ListeningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentScale = widget.initialScale;

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Adjust for smoothness
    );

    // Initialize the Animation with Tween
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: _currentScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.addListener(() {
      setState(() {
        _currentScale = _scaleAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Updates the scale based on the normalized sound level.
  void updateScale(double normalizedLevel) {
    // Calculate the target scale
    double targetScale = AudioUtils.getScale(
      normalizedLevel,
      _currentScale,
      widget.minScale,
      widget.maxScale,
    );

    // Update the Tween and restart the animation
    _scaleAnimation = Tween<double>(
      begin: _currentScale,
      end: targetScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _currentScale,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              const Color.fromARGB(255, 152, 163, 180).withOpacity(1.0 -
                  ((_currentScale - widget.minScale) / (0.2)).clamp(0.0, 1.0)),
              Colors.transparent
            ],
            stops: const [1.0, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Lottie.asset(
          'assets/record_example.json',
          width: min(widget.width - 50, 400),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
