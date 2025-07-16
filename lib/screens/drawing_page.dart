import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/draw_line.dart';
import '../widgets/DrawingToolsDrawer.dart';
import '../widgets/drawing_painter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawingToolsDrawer(
        selectedTool: selectedTool,
        selectedColor: selectedColor,
        strokeWidth: strokeWidth,
        onToolSelected: (tool) => setState(() => selectedTool = tool),
        onColorSelected: (color) => setState(() {
          selectedColor = color;
          selectedTool = ToolType.brush;
        }),
        onStrokeWidthChanged: (width) => setState(() => strokeWidth = width),
        onUndo: undo,
        onRedo: redo,
        onShapeDrawn: drawShape,
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