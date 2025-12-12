import 'package:flutter/material.dart';


class AppColors {
  // LearnInfoWidget
  static const Color learnInfoBackground = Color(0xFFE9E8E8);
  static const Color learnInfoBorder = Color(0xFFC4C4C4);

  // LearnWidget & LevelWidget
  static const Color circleBorder = Color(0xFFC4C4C4);
  static const Color circleFill = Color(0xFF72BFC7);
  static const Color circleInnerBorder = Colors.white;

  // General
  static const Color textBlack = Colors.black;
  static const Color textWhite = Colors.white;
}


class AppSizes {
  // LearnInfoWidget
  static const double learnInfoWidth = 211;
  static const double learnInfoHeight = 128;
  static const double learnInfoBorderRadius = 10;
  static const double learnInfoBorderWidth = 2;

  // LearnWidget & LevelWidget
  static const double circleSize = 140;
  static const double circleBorderWidthOuter = 10;
  static const double circleBorderWidthInner = 5;
  static const double circleMargin = 20;

  // Icons and text
  static const double iconSize = 50.0;
  static const double learnInfoFontSize = 34.0;
  static const double levelTextFontSize = 40.0;
}


class AppTextStyles {
  static const TextStyle learnInfoText = TextStyle(
    fontSize: AppSizes.learnInfoFontSize,
    color: AppColors.textBlack,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle levelText = TextStyle(
    fontFamily: 'Roboto',
    fontSize: AppSizes.levelTextFontSize,
    color: AppColors.textWhite,
  );
}
