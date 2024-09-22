// loading_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  final String loadingInfo;
  final double fontSize;

  const LoadingWidget(
      {super.key, required this.loadingInfo, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // This centers the content horizontally

        mainAxisSize: MainAxisSize.min, // This centers the Column vertically
        children: [
          LoadingAnimationWidget.discreteCircle(
            color: Colors.blueAccent,
            size: 100,
          ),
          const SizedBox(
            height: 25,
          ),
          Text(
            loadingInfo,
            textAlign: TextAlign
                .center, // Center the text content within the Text widget

            style: GoogleFonts.imFellDoublePica(
              textStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
