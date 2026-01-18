import 'package:flutter/material.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/widgets/match_pairs_widget.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class MatchPairsScreen extends StatefulWidget {
  final PairsData data;
  final VoidCallback onSuccess;

  const MatchPairsScreen({
    super.key,
    required this.data,
    required this.onSuccess,
  });

  @override
  State<MatchPairsScreen> createState() => _MatchPairsScreenState();
}

class _MatchPairsScreenState extends State<MatchPairsScreen> {
  late List<CardItem> cards;
  List<CardItem> selected = [];
  bool _locked = false;

  @override
  void initState() {
    super.initState();

    cards = widget.data.cards
        .take(widget.data.pairsCount * 2)
        .map(
          (c) => CardItem(
            id: c.id,
            pairId: c.pairId,
            value: c.value,
            isMatched: false,
            isFailed: false,
          ),
        )
        .toList();
  }

  void _onCardTap(CardItem card) {
    if (_locked) return;
    if (card.isMatched) return;

    setState(() {
      selected.add(card);
    });

    if (selected.length < 2) return;

    final first = selected[0];
    final second = selected[1];

    // MATCH FOUND
    if (first.id == second.pairId || second.id == first.pairId) {
      setState(() {
        first.isMatched = true;
        second.isMatched = true;
        selected.clear();
      });

      if (cards.every((c) => c.isMatched)) {
        Future.delayed(const Duration(milliseconds: 400), () {
          widget.onSuccess();
        });
      }

      return;
    }

    // MATCH FAILED
    setState(() {
      first.isFailed = true;
      second.isFailed = true;
      _locked = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        first.isFailed = false;
        second.isFailed = false;
        selected.clear();
        _locked = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: AppSizes.spacingLarge),

        Center(
          child: Text(
            "Match the pairs",
            style: AppTextStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppSizes.spacingXLarge),

        Column(
          children: [
            _buildRow(0, 1),
            const SizedBox(height: AppSizes.spacingLarge),
            _buildRow(2, 3),
            const SizedBox(height: AppSizes.spacingLarge),
            _buildRow(4, 5),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(int i, int j) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MatchPairsWidget(
          cards[i],
          isSelected: selected.any((c) => c.id == cards[i].id),
          isMatched: cards[i].isMatched,
          onTap: () => _onCardTap(cards[i]),
        ),

        const SizedBox(width: AppSizes.spacingXLarge),

        MatchPairsWidget(
          cards[j],
          isSelected: selected.any((c) => c.id == cards[j].id),
          isMatched: cards[j].isMatched,
          onTap: () => _onCardTap(cards[j]),
        ),
      ],
    );
  }
}
