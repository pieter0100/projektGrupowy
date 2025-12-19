import 'package:flutter/material.dart';

import 'package:projekt_grupowy/utils/constants.dart';
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
      backgroundColor = AppColors.matchError;
    } else if (isMatched) {
      backgroundColor = AppColors.matchSuccess;
    } else {
      backgroundColor = AppColors.matchDefault;
    }

    final double fontSize = card.value.length > 2 ? AppSizes.fontSizeCardSmall : AppSizes.fontSizeCardBig;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: AppSizes.matchCardSize,
            height: AppSizes.matchCardSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.matchCardRadius),
            ),
            child: Stack(
              children: [
                if (isSelected || isMatched || card.isFailed)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.matchCardRadius),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.matchShadow.withValues(alpha: 0.2),
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
                    style: AppTextStyles.matchCard(fontSize),
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
