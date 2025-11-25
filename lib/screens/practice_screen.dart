import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';

class PracticeScreen extends StatelessWidget{
  final String? level;

  const PracticeScreen({super.key, this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level'),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Practice screen'),
        backgroundColor: Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          SizedBox(height: 40),
          Center(
            child: MatchPairsWidget("2"),
          ),
        ],
        
      ),
    );
  }
}