import 'package:flutter/material.dart';

import 'package:projekt_grupowy/models/cards/card_item.dart';

class MatchPairsWidget extends StatelessWidget {
  final CardItem card;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback? onTap;

  const MatchPairsWidget(
    this.card, {
    super.key,
    this.isSelected = false,
    this.isMatched = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (card.isFailed) {
      backgroundColor = const Color(0xFFE15D5D);
    } else if (isMatched) {
      backgroundColor = const Color(0xFF7EDE81);
    } else {
      backgroundColor = const Color(0xFF7ED4DE);
    }

    final double fontSize = card.value.length > 2 ? 56 : 82;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                if (isSelected || isMatched || card.isFailed)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.1],
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Text(
                    card.value,
                    style: TextStyle(fontSize: fontSize, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
