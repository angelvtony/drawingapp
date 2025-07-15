// All necessary imports
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lottie/lottie.dart';
import '../models/draw_line.dart';
import '../services/websocket_service.dart';
import '../services/voice_service.dart';

enum ToolType { brush, eraser, line, rectangle, circle }

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
  ToolType selectedTool = ToolType.brush;

  Path? currentPath;
  Paint? currentPaint;
  Offset? startPoint;

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

  void drawShape(ToolType shape) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    switch (shape) {
      case ToolType.circle:
        final rect = Rect.fromCircle(center: center, radius: 100.0);
        path.addOval(rect);
        break;
      case ToolType.rectangle:
        final rect = Rect.fromCenter(center: center, width: 200, height: 100);
        path.addRect(rect);
        break;
      default:
        return;
    }

    final paint = Paint()
      ..color = selectedColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    setState(() {
      lines.add(DrawnLine(path: path, paint: paint));
    });
  }

  void startDrawing(Offset point) {
    setState(() {
      startPoint = point;
      currentPath = Path()..moveTo(point.dx, point.dy);
      currentPaint = Paint()
        ..color = selectedTool == ToolType.eraser ? Colors.white : selectedColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (selectedTool == ToolType.brush || selectedTool == ToolType.eraser) {
        lines.add(DrawnLine(path: currentPath!, paint: currentPaint!));
      }
    });
  }

  void updateDrawing(Offset point) {
    if (startPoint == null) return;

    setState(() {
      if (selectedTool == ToolType.brush || selectedTool == ToolType.eraser) {
        currentPath!.lineTo(point.dx, point.dy);
      } else {
        currentPath = Path();
        switch (selectedTool) {
          case ToolType.line:
            currentPath!.moveTo(startPoint!.dx, startPoint!.dy);
            currentPath!.lineTo(point.dx, point.dy);
            break;
          case ToolType.rectangle:
            currentPath!.addRect(Rect.fromPoints(startPoint!, point));
            break;
          case ToolType.circle:
            currentPath!.addOval(Rect.fromPoints(startPoint!, point));
            break;
          default:
            break;
        }
      }
    });

    if (selectedTool == ToolType.brush) {
      final points = <List<double>>[];
      final metrics = currentPath!.computeMetrics();
      for (final metric in metrics) {
        for (double t = 0; t < metric.length; t += 1.0) {
          final pos = metric.getTangentForOffset(t)?.position;
          if (pos != null) points.add([pos.dx, pos.dy]);
        }
      }

      if (points.isNotEmpty) {
        ws.sendDrawing({
          'points': points,
          'color': selectedColor.value.toString(),
          'width': strokeWidth,
        });
      }
    }
  }

  void endDrawing() {
    if ((selectedTool != ToolType.brush && selectedTool != ToolType.eraser) &&
        currentPath != null) {
      lines.add(DrawnLine(path: currentPath!, paint: currentPaint!));
    }
    currentPath = null;
    currentPaint = null;
    startPoint = null;
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

  void openColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
                selectedTool = ToolType.brush;
              });
            },
            enableAlpha: false,
            displayThumbColor: true,
            showLabel: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    ws.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.white.withOpacity(0.85),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Drawing Tools',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.undo),
                title: const Text('Undo'),
                onTap: () {
                  undo();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.redo),
                title: const Text('Redo'),
                onTap: () {
                  redo();
                  Navigator.pop(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.brush,
                    color: selectedTool == ToolType.brush
                        ? selectedColor
                        : Colors.grey),
                title: const Text('Brush'),
                onTap: () {
                  setState(() => selectedTool = ToolType.brush);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.auto_fix_normal,
                    color: selectedTool == ToolType.eraser
                        ? selectedColor
                        : Colors.grey),
                title: const Text('Eraser'),
                onTap: () {
                  setState(() => selectedTool = ToolType.eraser);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.show_chart,
                    color: selectedTool == ToolType.line
                        ? selectedColor
                        : Colors.grey),
                title: const Text('Line'),
                onTap: () {
                  setState(() => selectedTool = ToolType.line);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.crop_square,
                    color: selectedTool == ToolType.rectangle
                        ? selectedColor
                        : Colors.grey),
                title: const Text('Rectangle'),
                onTap: () {
                  setState(() => selectedTool = ToolType.rectangle);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.circle_outlined,
                    color: selectedTool == ToolType.circle
                        ? selectedColor
                        : Colors.grey),
                title: const Text('Circle'),
                onTap: () {
                  setState(() => selectedTool = ToolType.circle);
                  Navigator.pop(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.color_lens, color: selectedColor),
                title: const Text('Color Picker'),
                onTap: () {
                  Navigator.pop(context);
                  openColorPicker();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thickness:"),
                    Slider(
                      value: strokeWidth,
                      min: 1.0,
                      max: 20.0,
                      divisions: 19,
                      label: strokeWidth.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          strokeWidth = value;
                        });
                      },
                    ),
                    Center(
                      child: Text("${strokeWidth.toStringAsFixed(1)}"),
                    ),
                  ],
                ),
              ),
              Divider(),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Voice Command'),
                onTap: () async {
                  Navigator.pop(context);

                  final command = await voice.recordAndRecognize();
                  debugPrint("🎤 Transcribed: $command");
                  voice.speak("Command: $command");

                  final cmd = command.toLowerCase();

                  setState(() {
                    if (cmd.contains("red")) {
                      selectedColor = Colors.red;
                      selectedTool = ToolType.brush;
                    } else if (cmd.contains("black")) {
                      selectedColor = Colors.black;
                      selectedTool = ToolType.brush;
                    } else if (cmd.contains("yellow")) {
                      selectedColor = Colors.yellow;
                      selectedTool = ToolType.brush;
                    } else if (cmd.contains("eraser")) {
                      selectedTool = ToolType.eraser;
                    } else if (cmd.contains("line")) {
                      selectedTool = ToolType.line;
                    } else if (cmd.contains("rectangle")) {
                      selectedTool = ToolType.rectangle;
                      drawShape(ToolType.rectangle);
                    } else if (cmd.contains("circle")) {
                      selectedTool = ToolType.circle;
                      drawShape(ToolType.circle);
                    } else {
                      voice.speak("Sorry, I didn't understand that.");
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) => startDrawing(details.localPosition),
            onPanUpdate: (details) => updateDrawing(details.localPosition),
            onPanEnd: (details) => endDrawing(),
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              painter: DrawingPainter(lines, currentPath, currentPaint),
              size: Size.infinite,
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: Builder(
              builder: (context) => FloatingActionButton(
                mini: true,
                child: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Lottie.network(
              'https://assets7.lottiefiles.com/packages/lf20_tutvdkg0.json',
              height: 100,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, size: 50, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

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