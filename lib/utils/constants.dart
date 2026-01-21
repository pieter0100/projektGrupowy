import 'package:flutter/material.dart';

class AppColors {
  // LearnInfoWidget
  static const Color learnInfoBackground = Color(0xFFE9E8E8);
  static const Color learnInfoBorder = Color(0xFFC4C4C4);

  // LevelWidget & LearnWidget
  static const Color levelCircleBorder = Color(0xFFC4C4C4);
  static const Color levelCircleFill = Color(0xFF72BFC7);
  static const Color levelCircleInnerBorder = Colors.white;
  static const Color learnAppBarBackground = AppColors.appBarBackground;
  static const Color learnAppBarIcon = AppColors.black;
  static const Color learnTitle = AppColors.black;

  // MatchPairsWidget
  static const Color matchDefault = Color(0xFF7ED4DE);
  static const Color matchSuccess = Color(0xFF7EDE81);
  static const Color matchError = Color(0xFFE15D5D);
  static const Color matchShadow = Colors.black;

  // ProgressBar
  static const Color progressBackground = Color(0xFFE8E8E8);
  static const Color progressFill = Color(0xFFF3C324);

  // Navigation (ScaffoldWithNav)
  static const Color navBackground = Color(0xFFE5E5E5);
  static const Color navShadow = Colors.black;
  static const Color navHome = Color(0xFF41AC78);
  static const Color navLeaderboard = Color(0xFFEB9F4A);
  static const Color navProfile = Color(0xFFAB70DF);
  static const Color navSettings = Color(0xFF729ED8);
  static Color navUnselected = Colors.grey.shade600;

  // SettingsWidget
  static const Color settingsBorder = Color(0xFFC4C4C4);
  static const Color settingsAccountIcon = Color.fromARGB(255, 206, 190, 245);

  // LevelScreen
  static const Color Orange = Color(0xFFEB9F4A);
  static const Color Blue = Color(0xFF338F9B);

  // McScreen
  static const Color appBarBackgroundMC = Color(0xFFE5E5E5);
  static const Color mcTitleText = AppColors.black;
  static const Color mcQuestionText = AppColors.black;

  // TypedScreen
  static const Color typedAppBarBackground = Color(0xFFE5E5E5);
  static const Color typedTitleText = AppColors.black;
  static const Color typedQuestionText = AppColors.black;
  static const Color typedInputDefault = Color(0xFFD9D9D9);
  static const Color typedInputCorrect = Color(0xFFB2F2BB);
  static const Color typedInputWrong = Color(0xFFF5C2C2);
  static const Color typedBorderCorrect = Colors.green;
  static const Color typedBorderWrong = Colors.red;
  static const Color typedFocusedBorder = Color(0xFF7ED4DE);
  static const Color typedHint = Color(0xFF757575);
  static const Color typedSkipText = Color(0xFF757575);

  // TypedScreenEnd
  static const Color examEndTitle = AppColors.black;
  static const Color examEndButtonBackground = AppColors.levelCircleFill;
  static const Color examEndButtonText = AppColors.white;

  // PracticeScreen
  static const Color practiceAppBarBackground = AppColors.appBarBackground;
  static const Color practiceTitle = AppColors.black;
  static const Color practiceCloseIcon = AppColors.black;

  // General
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color appBarBackground = Color(0xFFE5E5E5);
}

class AppSizes {
  // Icons
  static const double iconLarge = 50.0;
  static const double iconMedium = 35.0;

  // LearnInfo
  static const double learnInfoWidth = 211.0;
  static const double learnInfoHeight = 128.0;
  static const double learnInfoRadius = 10.0;
  static const double learnInfoBorderWidth = 2.0;

  // LevelWidget & LearnWidget
  static const double levelCircleSize = 140.0;
  static const double levelCircleBorderOuter = 10.0;
  static const double levelCircleBorderInner = 5.0;
  static const double levelCircleMargin = 20.0;
  static const double learnTopSpacing = 40.0;
  static const double learnItemSpacing = 16.0;
  static const double learnLabelSpacing = 8.0;
  static const double learnLabelFontSize = 20.0;

  // MatchPairs
  static const double matchCardSize = 130.0;
  static const double matchCardRadius = 12.0;
  static const double fontSizeCardBig = 82.0;
  static const double fontSizeCardSmall = 56.0;

  // ProgressBar
  static const double progressWidth = 330.0;
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

  // McScreen
  static const double mcProgressTopMargin = 20.0;
  static const double mcTitleTopMargin = 10.0;
  static const double mcTitleFontSize = 30.0;
  static const double mcQuestionFontSize = 48.0;
  static const double mcCardMargin = 20.0;
  static const double mcPaddingTop = 10.0;
  static const double mcPaddingHorizontal = 40.0;
  static const double mcPaddingBottom = 100.0;

  // TypedScreen
  static const double typedProgressTopMargin = 20.0;
  static const double typedTitlePadding = 30.0;
  static const double typedTitleFontSize = 30.0;
  static const double typedQuestionFontSize = 48.0;
  static const double typedInputFontSize = 25.0;
  static const double typedInputPaddingH = 24.0;
  static const double typedInputPaddingV = 16.0;
  static const double typedInputBorderRadius = 16.0;
  static const double typedInputBorderWidth = 3.0;
  static const double typedFieldPaddingStart = 35.0;
  static const double typedFieldPaddingEnd = 35.0;
  static const double typedFieldPaddingTop = 35.0;
  static const double typedFieldPaddingBottom = 40.0;
  static const double typedSkipFontSize = 16.0;
  static const double typedSkipBottomSpacing = 180.0;
  static const double typedInputSpacing = 20.0;

  // TypedScreenEnd
  static const double examEndTitleSize = 32.0;
  static const double examEndSpacing = 20.0;
  static const double examEndButtonFontSize = 20.0;
  static const double examEndButtonWidth = 200.0;
  static const double examEndButtonHeight = 55.0;

  // PracticeScreen
  static const double practiceAppBarFontSize = 20.0;
  static const double practiceTopSpacing = 10.0;
  static const double practiceProgressSpacing = 20.0;

  //Screen Spacings
  static const double screenPaddingTop = 40.0;
  static const double screenPaddingMedium = 29.0;
  static const double screenPaddingLarge = 57.0;
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 35.0;
  static const double spacingXLarge = 53.0;
  static const double progressToTitleMargin = 42.0;

  // Text Font Sizes
  static const double fontSizeAppBar = 20.0;
  static const double fontSizeStats = 23.0;
  static const double fontSizeSectionTitle = 30.0;
  static const double fontSizeCongratulations = 24.0;
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
    fontSize: AppSizes.settingsFontSize,
    color: AppColors.black,
  );

  static TextStyle matchCard(double size) =>
      TextStyle(fontSize: size, color: AppColors.white);

  static const TextStyle sectionTitle = TextStyle(
    fontSize: AppSizes.fontSizeSectionTitle,
  );

  static const TextStyle mcTitle = TextStyle(
    fontSize: AppSizes.mcTitleFontSize,
    color: AppColors.mcTitleText,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle mcQuestion = TextStyle(
    fontSize: AppSizes.mcQuestionFontSize,
    color: AppColors.mcQuestionText,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle typedTitle = TextStyle(
    fontSize: AppSizes.typedTitleFontSize,
    color: AppColors.typedTitleText,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle typedQuestion = TextStyle(
    fontSize: AppSizes.typedQuestionFontSize,
    color: AppColors.typedQuestionText,
  );

  static const TextStyle typedInput = TextStyle(
    fontSize: AppSizes.typedInputFontSize,
    color: AppColors.black,
  );

  static const TextStyle typedSkip = TextStyle(
    fontSize: AppSizes.typedSkipFontSize,
    color: AppColors.typedSkipText,
  );

  static const TextStyle examEndTitle = TextStyle(
    fontSize: AppSizes.examEndTitleSize,
    fontWeight: FontWeight.bold,
    color: AppColors.examEndTitle,
  );

  static const TextStyle examEndButtonText = TextStyle(
    fontSize: AppSizes.examEndButtonFontSize,
    color: AppColors.examEndButtonText,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle practiceTitle = TextStyle(
    fontSize: AppSizes.practiceAppBarFontSize,
    color: AppColors.practiceTitle,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle learnLabel = TextStyle(
    fontSize: AppSizes.learnLabelFontSize,
    color: AppColors.black,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle learnTitle = TextStyle(
    fontSize: AppSizes.fontSizeAppBar,
    color: AppColors.learnTitle,
    fontWeight: FontWeight.w600,
  );
}
