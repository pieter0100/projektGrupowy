import 'package:flutter/material.dart';

import 'package:projekt_grupowy/utils/constants.dart';

class LearnInfoWidget extends StatelessWidget {
  final String textInside;

  const LearnInfoWidget(this.textInside, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.learnInfoWidth,
      height: AppSizes.learnInfoHeight,
      decoration: BoxDecoration(
        color:  AppColors.learnInfoBackground, // background color
        border: Border.all(
          color: AppColors.learnInfoBorder, // border color
          width: AppSizes.learnInfoBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppSizes.learnInfoRadius),
      ),
      child: Center(
        child: Text(
          textInside,
          style: AppTextStyles.learnInfo,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}