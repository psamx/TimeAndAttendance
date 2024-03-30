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
  static void showConfirmationPopup(BuildContext context, String popUpTitle, String popUpText, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(popUpTitle),
          content: Text(popUpText),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text("Yes")
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No")
            ),
          ],
        );
      },
    );
  }
}
