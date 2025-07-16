import 'package:flutter/material.dart';
import '../models/draw_line.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final Path? currentPath;
  final Paint? currentPaint;

  DrawingPainter(this.lines, this.currentPath, this.currentPaint);

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      canvas.drawPath(line.path, line.paint);
    }
    if (currentPath != null && currentPaint != null) {
      canvas.drawPath(currentPath!, currentPaint!);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}