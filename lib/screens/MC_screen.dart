import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class McScreen extends StatelessWidget {
  const McScreen({super.key});

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
      body: ListView(
        children: [
          Column(
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
                "(np 2 x 2) dane z Question provider",
                style: TextStyle(fontSize: 48.0),
                textAlign: TextAlign.center,
              ),
              Column(
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
            ],
          ),
        ],
      ),
    );
  }
}
