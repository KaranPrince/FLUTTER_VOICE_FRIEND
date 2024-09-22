import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../../utils/audio_utils.dart';

class PlayingAnimation extends StatefulWidget {
  final double width;
  final double initialScale;
  final double minScale;
  final double maxScale;

  const PlayingAnimation({
    super.key,
    required this.width,
    this.initialScale = 1.0,
    this.minScale = 0.5,
    this.maxScale = 2.0,
  });

  @override
  PlayingAnimationState createState() => PlayingAnimationState();
}

class PlayingAnimationState extends State<PlayingAnimation>
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
    double targetScale = AudioUtils.getOutputScale(
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

  Color _getColorForScale(double scale) {
    // Keep lightness constant for consistent brightness
    const lightness = 0.75;
    // Normalize the scale between 0 and 1
    final normalizedScale =
        ((scale - widget.minScale) / (widget.maxScale - widget.minScale))
            .clamp(0.0, 1.0);
    // Calculate hue based on normalized scale (0 to 360 degrees)
    final hue = 360.0 * normalizedScale;
    // Increase saturation with scale; starts at 0 (grey) and goes to 1 (full color)
    final saturation = (4 * (normalizedScale - 0.25)).clamp(0.0, 1.0);
    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    // Get the dynamic color based on current scale
    final dynamicColor = _getColorForScale(_currentScale);

    return Transform.scale(
      scale: _currentScale,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              dynamicColor.withOpacity(1.0),
              Colors.transparent,
            ],
            stops: const [0.7, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop, // Ensures transparency is preserved
        child: Lottie.asset(
          'assets/play_example.json',
          width: min(widget.width - 50, 400),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
