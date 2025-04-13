import 'package:flutter/material.dart';
import 'level_selection_screen.dart';

void main() {
  runApp(CandyCrushApp());
}

class CandyCrushApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candy Crush Clone',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: LevelSelectionScreen(),
    );
  }
}