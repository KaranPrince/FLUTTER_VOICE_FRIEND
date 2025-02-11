import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool?> showIntroductionActivityCompletionDialog(
    BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Activity Completed',
          style: GoogleFonts.imFellDoublePica(
            textStyle: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          'Click on Continue to go to the main menu',
          style: GoogleFonts.imFellDoublePica(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent, // Button color
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context)
                  .pop(false); // Return false when restart is pressed
            },
            child: Text(
              'Continue',
              style: GoogleFonts.imFellDoublePica(
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<bool?> showActivityCompletionDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Activity Completed',
          style: GoogleFonts.imFellDoublePica(
            textStyle: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          'Would you like to return to the main menu or restart the activity?',
          style: GoogleFonts.imFellDoublePica(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent, // Button color
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context)
                  .pop(false); // Return false when restart is pressed
            },
            child: Text(
              'Restart',
              style: GoogleFonts.imFellDoublePica(
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // Return true when main menu is pressed
            },
            child: Text(
              'Main Menu',
              style: GoogleFonts.imFellDoublePica(
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
