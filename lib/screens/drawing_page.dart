import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/draw_line.dart';
import '../services/websocket_service.dart';
import '../services/voice_service.dart';
import '../widgets/color_dot.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawnLine> lines = [];
  List<DrawnLine> undoStack = [];

  Color selectedColor = Colors.black;
  double strokeWidth = 4.0;
  bool isEraser = false;
  Path currentPath = Path();

  late WebSocketService ws;
  late VoiceService voice;

  @override
  void initState() {
    super.initState();
    ws = WebSocketService();
    voice = VoiceService();

    ws.stream.listen((event) {
      final data = jsonDecode(event);
      final path = Path();
      final points = data['points'] as List;
      if (points.isNotEmpty) {
        path.moveTo(points[0][0], points[0][1]);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i][0], points[i][1]);
        }
      }

      final paint = Paint()
        ..color = Color(int.parse(data['color']))
        ..strokeWidth = data['width']
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      setState(() {
        lines.add(DrawnLine(path: path, paint: paint));
      });
    });
  }

  void startDrawing(Offset point) {
    currentPath = Path()..moveTo(point.dx, point.dy);
    final paint = Paint()
      ..color = isEraser ? Colors.white : selectedColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    lines.add(DrawnLine(path: currentPath, paint: paint));
  }

  void updateDrawing(Offset point) {
    setState(() {
      currentPath.lineTo(point.dx, point.dy);
    });

    final points = <List<double>>[];
    for (final metric in currentPath.computeMetrics()) {
      for (double t = 0; t < metric.length; t += 1.0) {
        final pos = metric.getTangentForOffset(t)?.position;
        if (pos != null) points.add([pos.dx, pos.dy]);
      }
    }

    ws.sendDrawing({
      'points': points,
      'color': selectedColor.value.toString(),
      'width': strokeWidth,
    });
  }

  void undo() {
    if (lines.isNotEmpty) {
      setState(() {
        undoStack.add(lines.removeLast());
      });
    }
  }

  void redo() {
    if (undoStack.isNotEmpty) {
      setState(() {
        lines.add(undoStack.removeLast());
      });
    }
  }

  @override
  void dispose() {
    ws.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) => startDrawing(details.localPosition),
            onPanUpdate: (details) => updateDrawing(details.localPosition),
            child: CustomPaint(
              painter: DrawingPainter(lines),
              child: Container(color: Colors.white),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: Icon(Icons.undo), onPressed: undo),
                IconButton(icon: Icon(Icons.redo), onPressed: redo),
                IconButton(
                  icon: Icon(Icons.brush, color: isEraser ? Colors.grey : selectedColor),
                  onPressed: () => setState(() => isEraser = false),
                ),
                IconButton(
                  icon: Icon(Icons.auto_fix_normal, color: isEraser ? selectedColor : Colors.grey),
                  onPressed: () => setState(() => isEraser = true),
                ),
                ColorDot(color: Colors.black, onTap: () => setState(() => selectedColor = Colors.black)),
                ColorDot(color: Colors.red, onTap: () => setState(() => selectedColor = Colors.red)),
                ColorDot(color: Colors.yellow, onTap: () => setState(() => selectedColor = Colors.yellow)),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () async {
                    final command = await voice.recordAndRecognize();
                    voice.speak("Command: $command");
                    if (command.toLowerCase().contains("red")) {
                      setState(() => selectedColor = Colors.red);
                    } else if (command.toLowerCase().contains("eraser")) {
                      setState(() => isEraser = true);
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Lottie.asset('assets/toolbar_animation.json', height: 100),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  DrawingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      canvas.drawPath(line.path, line.paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}