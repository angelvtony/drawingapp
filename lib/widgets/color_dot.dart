import 'package:flutter/material.dart';

class ColorDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const ColorDot({super.key, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }
}