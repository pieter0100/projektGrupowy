import 'package:flutter/material.dart';
import 'package:projekt_grupowy/widgets/level_widget.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Level screen',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      const SizedBox(width: 8),
      Icon(
        Icons.local_fire_department,
        color: Color(0xFFEB9F4A),
        size: 29,
      ),
      const SizedBox(width: 4),
      const Text(
        '3',
        style: TextStyle(
          fontSize: 23,
          color: Color(0xFFEB9F4A),
        ),
      ),
      const SizedBox(width: 8),
      Icon(
        Icons.diamond,
        color: Color(0xFF338F9B),
        size: 29,
      ),
      const SizedBox(width: 4),
      const Text(
        '1432 XP',
        style: TextStyle(
          fontSize: 23,
          color: Color(0xFF338F9B),
        ),
      ),
    ],
  ),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          if (index < 2) {
            return LevelWidget("x ${index + 1}");
          } else {
            return LevelWidget("lock");
          }
        },
      ),
    );
  }
}
