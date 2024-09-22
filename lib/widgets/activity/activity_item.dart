// activity_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityItem extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onSelectActivity;
  final bool isCompleted;
  final bool isUnlocked;
  final DateTime? lastCompleted; // Add this to show the timestamp

  const ActivityItem({
    super.key,
    required this.activity,
    required this.onSelectActivity,
    required this.isCompleted,
    required this.isUnlocked,
    this.lastCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final bool tabletMode = isTablet(context); // Determine if it's a tablet
    final double sizeMultiplier =
        tabletMode ? 1.75 : 1.0; // Multiply sizes for tablet

    return Stack(
      children: [
        GestureDetector(
          onTap: onSelectActivity,
          child: GridTile(
            footer: SizedBox(
              height: tabletMode ? 80 : 60,
              child: GridTileBar(
                backgroundColor: Colors.black54,
                title: Text(
                  activity.name,
                  style: GoogleFonts.imFellDoublePica(
                    textStyle: TextStyle(
                      fontSize: 18 * sizeMultiplier,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // Adds "..." for overflow

                  maxLines: 2, // Limits the text to two lines
                ),
              ),
            ),
            child: ColorFiltered(
              colorFilter: isCompleted
                  ? ColorFilter.mode(
                      Colors.white.withOpacity(0.5), BlendMode.screen)
                  : const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply),
              child: Image.asset(
                activity.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (isCompleted)
          Positioned(
            top: 8 * sizeMultiplier,
            left: 8 * sizeMultiplier,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white, // White background
                shape: BoxShape.circle, // Make the background a circle
              ),
              padding: const EdgeInsets.all(
                  4), // Padding to ensure some space between the icon and the background
              child: Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 20 * sizeMultiplier,
              ),
            ),
          ),
        // Show a lock icon if the activity is locked
        if (!isUnlocked)
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.lock,
                color: Colors.white,
                size: 50 * sizeMultiplier,
              ),
            ),
          ),
        // Position the duration tag in the top right corner and make it larger
        Positioned(
          top: 8 * sizeMultiplier,
          right: 8 * sizeMultiplier,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: 12 * sizeMultiplier, // Larger clock icon
                ),
                SizedBox(width: 6 * sizeMultiplier),
                Text(
                  "${activity.duration} min",
                  style: TextStyle(
                    fontSize: 12 * sizeMultiplier, // Larger text size
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }
}
