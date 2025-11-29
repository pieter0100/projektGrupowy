import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class PracticeScreen extends StatelessWidget{
  final String? level;

  const PracticeScreen({super.key, this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level/learn?level=${level}'),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Practice screen'),
        backgroundColor: Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          SizedBox(height: 29),
          Center(
            child: ProgressBarWidget(),
          ),
          SizedBox(height: 42),
          Center(
            child: Text(
              "Question 1",
              style: TextStyle(fontSize: 30),
            ),
          ),
          SizedBox(height: 57),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MatchPairsWidget("1"),
                  SizedBox(width: 53),
                  MatchPairsWidget("2"),
                ],
              ),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MatchPairsWidget("3"),
                  SizedBox(width: 53),
                  MatchPairsWidget("4"),
                ],
              ),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MatchPairsWidget("5"),
                  SizedBox(width: 53),
                  MatchPairsWidget("6"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}