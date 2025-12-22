import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:projekt_grupowy/services/mc_game_engine.dart';
import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class McScreen extends StatefulWidget {
  const McScreen({super.key});

  @override
  _McScreenState createState() => _McScreenState();
}

class _McScreenState extends State<McScreen> {
  String question = "Loading...";

  final engine = MCGameEngine(
    onComplete: (result) {
      print('Correct: ${result.isCorrect}');
      print('Answer: ${result.userAnswer}');
    },
  );

  @override
  void initState() {
    super.initState();

    // TODO change static value
    engine.initialize(3);

    question = engine.question.prompt;
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
                              CardItem(
                                id: "1",
                                pairId: "2",
                                value: "2",
                                isMatched: false,
                                isFailed: false,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: MatchPairsWidget(
                              CardItem(
                                id: "1",
                                pairId: "2",
                                value: "2",
                                isMatched: false,
                                isFailed: false,
                              ),
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
                              CardItem(
                                id: "1",
                                pairId: "2",
                                value: "2",
                                isMatched: false,
                                isFailed: false,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: MatchPairsWidget(
                              CardItem(
                                id: "1",
                                pairId: "2",
                                value: "2",
                                isMatched: false,
                                isFailed: false,
                              ),
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
