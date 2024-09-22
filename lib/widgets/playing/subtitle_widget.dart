// subtitle_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubtitleWidget extends StatelessWidget {
  final double width;
  final double subtitleSize;
  final String subtitles;
  final Color textColor;

  const SubtitleWidget({
    super.key,
    required this.width,
    required this.subtitleSize,
    required this.subtitles,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: width * 0.1,
      right: width * 0.1,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 750),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final fadeAnimation =
                Tween<double>(begin: 0.0, end: 1.0).animate(animation);
            final offsetAnimation =
                Tween<Offset>(begin: const Offset(0, 0.75), end: Offset.zero)
                    .animate(animation);
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          child: Text(
            subtitles,
            key: ValueKey<String>(subtitles),
            textAlign: TextAlign.center,
            style: GoogleFonts.imFellDoublePica(
              textStyle: TextStyle(
                fontSize: subtitleSize,
                color: textColor,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
