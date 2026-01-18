import 'package:flutter/material.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';

class McScreen extends StatefulWidget {
  final MultipleChoiceData data;
  final VoidCallback onSuccess;

  const McScreen({
    super.key,
    required this.data,
    required this.onSuccess,
  });

  @override
  State<McScreen> createState() => _McScreenState();
}

class _McScreenState extends State<McScreen> {
  late List<CardItem> cards;
  bool _locked = false;

  @override
  void initState() {
    super.initState();

    cards = [];

    for (var i = 0; i < widget.data.options.length; i++) {
      cards.add(
        CardItem(
          id: "$i",
          pairId: "-1",
          value: widget.data.options[i].toString(),
          isMatched: false,
          isFailed: false,
        ),
      );
    }
  }

  void _onOptionSelected(int index) {
    if (_locked) return;

    final isCorrect = widget.data.options[index] == widget.data.correctAnswer;

    setState(() {
      if (isCorrect) {
        cards[index].isMatched = true;
      } else {
        cards[index].isFailed = true;
      }
      _locked = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      if (isCorrect) {
        widget.onSuccess();
      } else {
        setState(() {
          cards[index].isFailed = false;
          _locked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        Text(
          "Choose the correct answer",
          style: const TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        Text(
          widget.data.question,
          style: const TextStyle(fontSize: 48),
          textAlign: TextAlign.center,
        ),

        Expanded(
          child: FittedBox(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                right: 40,
                left: 40,
                bottom: 100,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildCard(0),
                      const SizedBox(width: 40),
                      _buildCard(1),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      _buildCard(2),
                      const SizedBox(width: 40),
                      _buildCard(3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: MatchPairsWidget(
        cards[index],
        isMatched: cards[index].isMatched,
        isSelected: false,
        onTap: () => _onOptionSelected(index),
      ),
    );
  }
}
