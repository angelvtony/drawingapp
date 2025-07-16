import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/draw_line.dart';
import '../services/db_helper.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLines();
  }

  Future<void> _loadLines() async {
    final saved = await DBHelper.loadLines();
    setState(() => lines = saved);
  }

  Future<void> _saveLines() async {
    await DBHelper.saveLines(lines);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Drawing saved locally')));
  }

  void drawShape(ToolType shape) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    switch (shape) {
      case ToolType.circle:
        path.addOval(Rect.fromCircle(center: center, radius: 100));
        break;
      case ToolType.rectangle:
        path.addRect(Rect.fromCenter(center: center, width: 200, height: 100));
        break;
      default: return;
    }
    final paint = Paint()
      ..color = selectedColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    setState(() {
      lines.add(DrawnLine(path: path, paint: paint));
    });
    _saveLines();
  }

  void startDrawing(Offset pt) {
    startPoint = pt;
    currentPath = Path()..moveTo(pt.dx, pt.dy);
    currentPaint = Paint()
      ..color = selectedTool == ToolType.eraser ? Colors.white : selectedColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (selectedTool == ToolType.brush || selectedTool == ToolType.eraser) {
      lines.add(DrawnLine(path: currentPath!, paint: currentPaint!));
    }
    undoStack.clear();
  }

  void updateDrawing(Offset pt) {
    if (startPoint == null) return;
    setState(() {
      if (selectedTool == ToolType.brush || selectedTool == ToolType.eraser) {
        currentPath!.lineTo(pt.dx, pt.dy);
      } else {
        currentPath = Path();
        switch (selectedTool) {
          case ToolType.line:
            currentPath!.moveTo(startPoint!.dx, startPoint!.dy);
            currentPath!.lineTo(pt.dx, pt.dy);
            break;
          case ToolType.rectangle:
            currentPath!.addRect(Rect.fromPoints(startPoint!, pt));
            break;
          case ToolType.circle:
            currentPath!.addOval(Rect.fromPoints(startPoint!, pt));
            break;
          default:
            break;
        }
      }
    });
  }

  void endDrawing() {
    if (currentPath != null &&
        selectedTool != ToolType.brush &&
        selectedTool != ToolType.eraser) {
      lines.add(DrawnLine(path: currentPath!, paint: currentPaint!));
    }
    currentPath = null;
    currentPaint = null;
    startPoint = null;
    _saveLines();
  }

  void undo() {
    if (lines.isNotEmpty) {
      setState(() {
        undoStack.add(lines.removeLast());
      });
      _saveLines();
    }
  }

  void redo() {
    if (undoStack.isNotEmpty) {
      setState(() {
        lines.add(undoStack.removeLast());
      });
      _saveLines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawingToolsDrawer(
        selectedTool: selectedTool,
        selectedColor: selectedColor,
        strokeWidth: strokeWidth,
        onToolSelected: (t) => setState(() => selectedTool = t),
        onColorSelected: (c) => setState(() {
          selectedColor = c;
          selectedTool = ToolType.brush;
        }),
        onStrokeWidthChanged: (w) => setState(() => strokeWidth = w),
        onUndo: undo,
        onRedo: redo,
        onShapeDrawn: drawShape,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (d) => startDrawing(d.localPosition),
            onPanUpdate: (d) => updateDrawing(d.localPosition),
            onPanEnd: (d) => endDrawing(),
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
              builder: (ctx) => FloatingActionButton(
                mini: true,
                child: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
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
              errorBuilder: (c, e, st) =>
              const Icon(Icons.error, size: 50, color: Colors.red),
            ),
          ),
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton(
              child: const Icon(Icons.save),
              onPressed: _saveLines,
            ),
          ),
        ],
      ),
    );
  }
}