import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;


  const InfoRow({
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0), // Spacer between label and value
        Text(
          value,
          style: const TextStyle(fontSize: 18.0),
        ),
        const Divider(), // Divider after each group of label-data
      ],
    );
  }
}
