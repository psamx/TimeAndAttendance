import 'package:flutter/material.dart';

class PopupService {
  static void showResponsePopup(BuildContext context, String popUpTitle, String popUpText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(popUpTitle),
          content: Text(popUpText),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
