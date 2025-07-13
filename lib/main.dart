import 'package:drawingapp/screens/drawing_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DrawingApp());
}

class DrawingApp extends StatelessWidget {
  const DrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colab Drawing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DrawingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
