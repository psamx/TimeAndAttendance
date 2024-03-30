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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10.0),
          Text(value),
        ],
      ),
    );
  }
}
