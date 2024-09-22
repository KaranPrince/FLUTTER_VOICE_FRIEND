// image_of_activity.dart
import 'package:flutter/material.dart';

class ImageOfActivity extends StatelessWidget {
  final String imagePath;

  const ImageOfActivity({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imagePath,
          height: MediaQuery.of(context).size.height *
              0.45, // Set height to half the screen height
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black
                      .withOpacity(1.0), // Start with semi-transparent black
                  Colors.transparent, // Fade to transparent
                  Colors.transparent, // Fade to transparent
                  Colors.black
                      .withOpacity(1.0), // End with semi-transparent black
                ],
                stops: const [
                  0.0,
                  0.35,
                  0.65,
                  1.0
                ], // Adjust the gradient stops as needed
              ),
            ),
          ),
        ),
      ],
    );
  }
}
