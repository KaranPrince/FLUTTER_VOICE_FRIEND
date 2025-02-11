import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String errorMessage,
    {bool showOk = true}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Ouch !'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(errorMessage),
            ],
          ),
        ),
        actions: <Widget>[
          if (showOk)
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
        ],
      );
    },
  );
}
