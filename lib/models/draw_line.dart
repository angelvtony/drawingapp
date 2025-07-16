import 'package:flutter/material.dart';

class DrawnLine {
  Path path;
  Paint paint;
  DrawnLine({required this.path, required this.paint});
}

enum ToolType { brush, eraser, line, rectangle, circle }