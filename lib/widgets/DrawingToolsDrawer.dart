import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/draw_line.dart';

class DrawingToolsDrawer extends StatelessWidget {
  final ToolType selectedTool;
  final Color selectedColor;
  final double strokeWidth;
  final Function(ToolType) onToolSelected;
  final Function(Color) onColorSelected;
  final Function(double) onStrokeWidthChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final Function(ToolType) onShapeDrawn;

  const DrawingToolsDrawer({
    super.key,
    required this.selectedTool,
    required this.selectedColor,
    required this.strokeWidth,
    required this.onToolSelected,
    required this.onColorSelected,
    required this.onStrokeWidthChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onShapeDrawn,
  });

  void _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: onColorSelected,
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
  Widget build(BuildContext context) {
    return Drawer(
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
                onUndo();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.redo),
              title: const Text('Redo'),
              onTap: () {
                onRedo();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.brush,
                  color: selectedTool == ToolType.brush
                      ? selectedColor
                      : Colors.grey),
              title: const Text('Brush'),
              onTap: () {
                onToolSelected(ToolType.brush);
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
                onToolSelected(ToolType.eraser);
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
                onToolSelected(ToolType.line);
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
                onToolSelected(ToolType.rectangle);
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
                onToolSelected(ToolType.circle);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.color_lens, color: selectedColor),
              title: const Text('Color Picker'),
              onTap: () {
                Navigator.pop(context);
                _openColorPicker(context);
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
                    onChanged: onStrokeWidthChanged,
                  ),
                  Center(
                    child: Text("${strokeWidth.toStringAsFixed(1)}"),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Voice Command'),
              onTap: () async {
                Navigator.pop(context);
                // Voice command logic would go here
              },
            ),
          ],
        ),
      ),
    );
  }
}
