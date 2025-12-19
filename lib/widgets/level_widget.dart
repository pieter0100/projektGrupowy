import 'package:flutter/material.dart';

import 'package:projekt_grupowy/utils/constants.dart';

class LevelWidget extends StatelessWidget {
  final String textInside;
  final bool isLocked;

  const LevelWidget({this.textInside = "", required this.isLocked, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppSizes.levelCircleMargin),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.levelCircleBorder, width: AppSizes.levelCircleBorderOuter),
      ),
      width: AppSizes.levelCircleSize,
      height: AppSizes.levelCircleSize,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.levelCircleInnerBorder, width: AppSizes.levelCircleBorderInner),
            color: AppColors.levelCircleFill,
          ),
          child: (isLocked)
              ? Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Icon(Icons.lock, color: AppColors.black, size: AppSizes.iconLarge),
                  ),
                )
              : Center(
                  child: Text(
                    textInside,
                    style: AppTextStyles.levelText,
                  ),
                ),
        ),
      ),
    );
  }
}
