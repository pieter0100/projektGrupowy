import 'package:flutter/material.dart';

import 'package:projekt_grupowy/utils/constants.dart';

class LearnWidget extends StatelessWidget {
  final String textInside;

  const LearnWidget(this.textInside, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppSizes.circleMargin),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
          color: AppColors.circleBorder,
          width: AppSizes.circleBorderWidthOuter,
        ),
      ),
      width: AppSizes.circleSize,
      height: AppSizes.circleSize,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
            color: AppColors.circleInnerBorder,
            width: AppSizes.circleBorderWidthInner,
          ),
          color: AppColors.circleFill,
          ),
          child: (textInside == 'intro')
              ? Center(
                child: Icon(
                  Icons.menu_book,
                  color: AppColors.textWhite,
                  size: AppSizes.iconSize
                ),
            )
              :
          Center(
            child: (textInside == 'practice')
                ? Center(
              child: Icon(
                Icons.create,
                color: AppColors.textWhite,
                size: AppSizes.iconSize
              ),
            )
                :
            Center(
              child: Icon(
                Icons.edit_document,
                color: AppColors.textWhite,
                size: AppSizes.iconSize
              ),
            ),
          ),
        ),
      ),
    );
  }
}
