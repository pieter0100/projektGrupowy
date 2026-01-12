import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:projekt_grupowy/services/mc_game_engine.dart';
import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class McScreen extends StatefulWidget {
  final int level;

  const McScreen({super.key, required this.level});

  @override
  _McScreenState createState() => _McScreenState();
}

class _McScreenState extends State<McScreen> {
  String question = "Loading...";
  bool _isLocked = false;

  final engine = MCGameEngine(
    onComplete: (result) {
      print('Correct: ${result.isCorrect}');
      print('Answer: ${result.userAnswer}');
    },
  );

  List<CardItem> cards = [];

  @override
  void initState() {
    super.initState();

    engine.initialize(widget.level);

    question = engine.question.prompt;

    for (var index = 0; index < engine.question.options.length; index++) {
      cards.add(
        CardItem(
          id: "$index",
          pairId: "-1",
          value: engine.question.options[index],
          isMatched: false,
          isFailed: false,
        ),
      );
    }
  }

  void onOptionSelected(int index) {
    if (_isLocked) return; // Prevent multiple selections

    engine.selectOption(index);

    setState(() {
      if (index == engine.correctIndex) {
        cards[index].isMatched = true;
      } else {
        cards[index].isFailed = true;
      }
      _isLocked = true; // Lock further selections
    });

    // Show feedback for 1.5 seconds then proceed
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // For now, just go back
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("(np Multiply x 2) dane z Question provider"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(), // akcja powrotu
        ),
        backgroundColor: Color(0xFFE5E5E5),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: ProgressBarWidget(),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Text(
                "Choose the correct \n answer",
                style: TextStyle(fontSize: 30.0),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              question,
              style: TextStyle(fontSize: 48.0),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: FittedBox(
                alignment: AlignmentGeometry.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    right: 40.0,
                    left: 40.0,
                    bottom: 100.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: MatchPairsWidget(
                              cards[0],
                              isMatched: cards[0].isMatched,
                              onTap: () => onOptionSelected(0),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: MatchPairsWidget(
                              cards[1],
                              isMatched: cards[1].isMatched,
                              onTap: () => onOptionSelected(1),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: MatchPairsWidget(
                              cards[2],
                              isMatched: cards[2].isMatched,
                              onTap: () => onOptionSelected(2),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: MatchPairsWidget(
                              cards[3],
                              isMatched: cards[3].isMatched,
                              onTap: () => onOptionSelected(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
