import 'package:flutter/material.dart';

import 'package:projekt_grupowy/utils/constants.dart';

class LearnWidget extends StatelessWidget {
  final String textInside;

  const LearnWidget(this.textInside, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.levelCircleMargin),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.levelCircleBorder,
          width: AppSizes.levelCircleBorderOuter,
        ),
      ),
      width: AppSizes.levelCircleSize,
      height: AppSizes.levelCircleSize,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
            color: AppColors.levelCircleInnerBorder,
              width: AppSizes.levelCircleBorderInner,
          ),
          color: AppColors.levelCircleFill,
          ),
          child: (textInside == 'intro')
              ? Center(
                child: Icon(
                  Icons.menu_book,
                  color: AppColors.white,
                  size: AppSizes.iconLarge,
                ),
            )
              :
          Center(
            child: (textInside == 'practice')
                ? Center(
              child: Icon(
                Icons.create,
                color: AppColors.white,
                size: AppSizes.iconLarge,
              ),
            )
                :
            Center(
              child: Icon(
                Icons.edit_document,
                color: AppColors.white,
                size: AppSizes.iconLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
