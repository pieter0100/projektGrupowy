import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/widgets/learn_widget.dart';
import 'package:projekt_grupowy/widgets/learn_info_widget.dart';

class LearnScreen extends StatelessWidget {
  final String? level;

  const LearnScreen({super.key, this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level'),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Learn'),
        centerTitle: true,
        backgroundColor: Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          SizedBox(height: 40),
          Center(child: LearnInfoWidget("× $level")),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LearnWidget("intro"),
              SizedBox(height: 8),
              Text("Intro", style: TextStyle(fontSize: 20)),
              SizedBox(height: 16),
            ],
          ),
          Column( 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [ 
              GestureDetector( 
                onTap: () { 
                  context.go('/level/learn/practice?level=$level');
                }, 
                child: LearnWidget("practice"), 
              ), 
              const SizedBox(height: 8), 
              const Text("Practice", style: TextStyle(fontSize: 20)), 
              const SizedBox(height: 16), 
            ], 
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector( 
                onTap: () { 
                  context.go('/level/learn/exam?level=$level');
                }, 
                child: LearnWidget("exam"), 
              ),
              SizedBox(height: 8),
              Text("Exam", style: TextStyle(fontSize: 20)),
              SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
