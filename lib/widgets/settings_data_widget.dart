import 'package:flutter/material.dart';

import 'package:projekt_grupowy/utils/constants.dart';

class SettingsDataWidget extends StatelessWidget {
  final String textInside;

  const SettingsDataWidget(this.textInside, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.settingsWidth,
      height: AppSizes.settingsHeight,
      decoration: BoxDecoration(
        color: AppColors.white, // background color
        border: Border.all(
          color: AppColors.settingsBorder,
          width: AppSizes.settingsBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppSizes.settingsRadius),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle,
              color: AppColors.settingsAccountIcon,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSizes.settingsIconGap), // space between icon and text
            Text(
              textInside,
              style: AppTextStyles.settingsLabel,
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: AppSizes.settingsArrowGap),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.settingsBorder,
              size: AppSizes.iconMedium,
            ),
          ],
        ),
      ),
    );
  }
}