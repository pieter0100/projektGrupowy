import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

import 'package:projekt_grupowy/game_logic/round_manager.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';

class PracticeScreen extends StatefulWidget {
  final String? level;

  const PracticeScreen({super.key, this.level});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late RoundManager roundManager;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    final typeOfMultiplication = int.tryParse(widget.level ?? '1') ?? 1;
    roundManager = RoundManager(
      pairsAmount: 3,
      typeOfMultiplication: typeOfMultiplication,
    );
  }

  void _onCardTap(CardItem card) {
    if (_isLocked) return;

    final status = roundManager.onCardSelected(card);

    setState(() {});

    if (status == MatchStatus.matchFound) {
      roundManager.logGameState();
      roundManager.logMessage("Match found!");
    } else if (status == MatchStatus.matchFailed) {
      roundManager.logGameState();
      roundManager.logMessage("Match failed!");
      final failedCards = roundManager.selectedCards.toList();

      for (var c in failedCards) {
        c.isFailed = true;
      }
      _isLocked = true;
      setState(() {});

      Future.delayed(const Duration(seconds: 1), () {
        for (var c in failedCards) {
          c.isFailed = false;
        }
        roundManager.selectedCards.clear();
        _isLocked = false;
        setState(() {});
      });
    }

    if (roundManager.isRoundCompleted()) {
      context.go('/level/learn/practice/end?level=${widget.level}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = roundManager.currentDeck.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level/learn?level=${widget.level}'),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Practice screen'),
        backgroundColor: const Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 29),
          const Center(child: ProgressBarWidget()),
          const SizedBox(height: 42),

          const Center(
            child: Text("Question 1", style: TextStyle(fontSize: 30)),
          ),

          const SizedBox(height: 57),

          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MatchPairsWidget(
                    cards[0],
                    isSelected: roundManager.selectedCards.any(
                      (c) => c.id == cards[0].id,
                    ),
                    isMatched: cards[0].isMatched,
                    onTap: () => _onCardTap(cards[0]),
                  ),
                  const SizedBox(width: 53),
                  MatchPairsWidget(
                    cards[1],
                    isSelected: roundManager.selectedCards.any(
                      (c) => c.id == cards[1].id,
                    ),
                    isMatched: cards[1].isMatched,
                    onTap: () => _onCardTap(cards[1]),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MatchPairsWidget(
                    cards[2],
                    isSelected: roundManager.selectedCards.any(
                      (c) => c.id == cards[2].id,
                    ),
                    isMatched: cards[2].isMatched,
                    onTap: () => _onCardTap(cards[2]),
                  ),
                  const SizedBox(width: 53),
                  MatchPairsWidget(
                    cards[3],
                    isSelected: roundManager.selectedCards.any(
                      (c) => c.id == cards[3].id,
                    ),
                    isMatched: cards[3].isMatched,
                    onTap: () => _onCardTap(cards[3]),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MatchPairsWidget(
                    cards[4],
                    isSelected: roundManager.selectedCards.any(
                      (c) => c.id == cards[4].id,
                    ),
                    isMatched: cards[4].isMatched,
                    onTap: () => _onCardTap(cards[4]),
                  ),
                  const SizedBox(width: 53),
                  MatchPairsWidget(
                    cards[5],
                    isSelected: roundManager.selectedCards.any(
                      (c) => c.id == cards[5].id,
                    ),
                    isMatched: cards[5].isMatched,
                    onTap: () => _onCardTap(cards[5]),
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
