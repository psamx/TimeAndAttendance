import 'package:flutter/material.dart';

class ConditionalInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool condition; // Condition to determine the color

  const ConditionalInfoRow({
    required this.label,
    required this.value,
    required this.condition,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8.0), // Spacer between label and value
          Container(
            color: condition ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5), // Set background color based on condition
            child: Row(
              children: <Widget>[
                Text(
                  value,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
          const Divider(), // Divider after each group of label-data
        ],
      ),
    );
  }
}
