import 'package:flutter/material.dart';

class AppColors {
  // LearnInfoWidget
  static const Color learnInfoBackground = Color(0xFFE9E8E8);
  static const Color learnInfoBorder = Color(0xFFC4C4C4);

  // LevelWidget
  static const Color levelCircleBorder = Color(0xFFC4C4C4);
  static const Color levelCircleFill = Color(0xFF72BFC7);
  static const Color levelCircleInnerBorder = Colors.white;

  // MatchPairsWidget
  static const Color matchDefault = Color(0xFF7ED4DE);
  static const Color matchSuccess = Color(0xFF7EDE81);
  static const Color matchError = Color(0xFFE15D5D);
  static const Color matchShadow = Colors.black;

  // ProgressBar
  static const Color progressBackground = Color(0xFFE8E8E8);

  // Navigation (ScaffoldWithNav)
  static const Color navBackground = Color(0xFFE5E5E5);
  static const Color navShadow = Colors.black;
  static const Color navHome = Color(0xFF41AC78);
  static const Color navLeaderboard = Color(0xFFEB9F4A);
  static const Color navProfile = Color(0xFFAB70DF);
  static const Color navSettings = Color(0xFF729ED8);
  static Color navUnselected = Colors.grey.shade600;

  // Settings
  static const Color settingsBorder = Color(0xFFC4C4C4);
  static const Color settingsAccountIcon = Color.fromARGB(255, 206, 190, 245);

  // General
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

class AppSizes {
  // General & Icons
  static const double iconLarge = 50.0;
  static const double iconMedium = 35.0;

  // LearnInfo
  static const double learnInfoWidth = 211.0;
  static const double learnInfoHeight = 128.0;
  static const double learnInfoRadius = 10.0;
  static const double learnInfoBorderWidth = 2.0;

  // LevelWidget
  static const double levelCircleSize = 140.0;
  static const double levelCircleBorderOuter = 10.0;
  static const double levelCircleBorderInner = 5.0;
  static const double levelCircleMargin = 20.0;

  // MatchPairs
  static const double matchCardSize = 130.0;
  static const double matchCardRadius = 12.0;
  static const double fontSizeCardBig = 82.0;
  static const double fontSizeCardSmall = 56.0;

  // ProgressBar
  static const double progressWidth = 371.0;
  static const double progressHeight = 38.0;
  static const double progressRadius = 16.0;

  // Navigation
  static const double navWidthFactor = 0.8;
  static const double navRadius = 45.0;
  static const double navBottomMarginDefault = 10.0;
  static const double navBlurRadius = 10.0;
  static const double navSpreadRadius = 2.0;

  // Settings
  static const double settingsWidth = 378.0;
  static const double settingsHeight = 69.0;
  static const double settingsRadius = 20.0;
  static const double settingsBorderWidth = 2.0;
  static const double settingsPaddingLeft = 20.0;
  static const double settingsFontSize = 20.0;
  static const double settingsIconGap = 8.0;
  static const double settingsArrowGap = 130.0;
}

class AppTextStyles {
  static const TextStyle learnInfo = TextStyle(
    fontSize: 34.0,
    color: AppColors.black,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle levelText = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 40.0,
    color: AppColors.white,
  );

  static const TextStyle settingsLabel = TextStyle(
    fontSize: 20.0,
    color: AppColors.black,
  );
  
  static TextStyle matchCard(double size) => TextStyle(
    fontSize: size, 
    color: AppColors.white
  );
}