import 'package:flutter/material.dart';

class TrafficLightWidget extends StatelessWidget {
  final String status;
  final double size;

  const TrafficLightWidget({
    Key? key,
    required this.status,
    this.size = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lightSize = 70.0 * size;
    final containerWidth = 100.0 * size;
    final containerHeight = 330.0 * size; // 🔹 Increased height for 4 lights

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLight(Colors.red, status == "red", lightSize),
          _buildLight(Colors.amber, status == "yellow", lightSize),
          _buildLight(Colors.green, status == "green", lightSize),
          _buildLight(Colors.blue, status == "blue", lightSize), // 🔹 Added Blue Light
        ],
      ),
    );
  }

  Widget _buildLight(Color color, bool isActive, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ]
            : null,
      ),
    );
  }
}

class DateFormat {
  DateFormat(String s);

  static String format(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month $day, $hour:$minute';
  }
}
