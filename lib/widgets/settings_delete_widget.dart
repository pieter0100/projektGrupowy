import 'package:flutter/material.dart';

import 'package:projekt_grupowy/utils/constants.dart';

class SettingsDeleteWidget extends StatelessWidget {
  final String textInside;

  const SettingsDeleteWidget(this.textInside, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.settingsWidth,
      height: AppSizes.settingsHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.settingsBorder,
          width: AppSizes.settingsBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppSizes.settingsRadius),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSizes.settingsPaddingLeft),
          child: Row(
            children: [
              Icon(
                Icons.delete, 
                color: AppColors.black, 
                size: AppSizes.iconMedium
              ),
              const SizedBox(width: AppSizes.settingsIconGap),
              Text(
                textInside,
                style: AppTextStyles.settingsLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}