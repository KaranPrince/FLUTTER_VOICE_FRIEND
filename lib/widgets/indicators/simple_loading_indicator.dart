// simple_loading_circle.dart
import 'package:flutter/material.dart';

class SimpleLoadingCircle extends StatelessWidget {
  const SimpleLoadingCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      width: 80,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        strokeWidth: 8.0,
      ),
    );
  }
}
