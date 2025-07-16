import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';

class DrawnLine {
  Path path;
  Paint paint;

  DrawnLine({required this.path, required this.paint});

  Map<String, dynamic> toJson() {
    return {
      'path': jsonEncode(_serializePath(path)),
      'color': paint.color.value,
      'strokeWidth': paint.strokeWidth,
    };
  }

  static DrawnLine fromJson(Map<String, dynamic> json) {
    return DrawnLine(
      path: _deserializePath(jsonDecode(json['path'])),
      paint: Paint()
        ..color = Color(json['color'])
        ..strokeWidth = json['strokeWidth']
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  static List<List<double>> _serializePath(Path path) {
    final pathMetrics = path.computeMetrics();
    final points = <List<double>>[];

    for (final metric in pathMetrics) {
      for (double i = 0; i < metric.length; i += 1.0) {
        final tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          points.add([tangent.position.dx, tangent.position.dy]);
        }
      }
    }

    return points;
  }

  static Path _deserializePath(List<dynamic> points) {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points[0][0], points[0][1]);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i][0], points[i][1]);
    }
    return path;
  }
}


enum ToolType { brush, eraser, line, rectangle, circle }