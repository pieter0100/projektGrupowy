import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

import 'package:projekt_grupowy/models/card_generator.dart';

class PracticeScreen extends StatefulWidget {
  final String? level;

  const PracticeScreen({super.key, this.level});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late CardGenerator generator;

  @override
  void initState() {
    super.initState();

    generator = CardGenerator(
      pairsAmount: 3,
      typeOfMultiplication: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = generator.cardsDeck.take(6).toList();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level/learn?level=${widget.level}'),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Practice screen'),
        backgroundColor: Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          SizedBox(height: 29),
          Center(child: ProgressBarWidget()),
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
                  MatchPairsWidget(cards[0].value),
                  SizedBox(width: 53),
                  MatchPairsWidget(cards[1].value),
                ],
              ),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MatchPairsWidget(cards[2].value),
                  SizedBox(width: 53),
                  MatchPairsWidget(cards[3].value),
                ],
              ),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MatchPairsWidget(cards[4].value),
                  SizedBox(width: 53),
                  MatchPairsWidget(cards[5].value),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}