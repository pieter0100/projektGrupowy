import 'package:flutter/material.dart';

class LevelScreen extends StatelessWidget{
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level screen'),
      ),
      body: Center(
        child: Text('Level screen page')
      ),
    );
  }
}