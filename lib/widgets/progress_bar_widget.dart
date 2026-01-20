import 'package:flutter/material.dart';

import 'package:projekt_grupowy/utils/constants.dart';

class ProgressBarWidget extends StatelessWidget {

  const ProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.progressWidth,
      height: AppSizes.progressHeight,
      decoration: BoxDecoration(
        color: AppColors.progressBackground,
        borderRadius: BorderRadius.circular(AppSizes.progressRadius),
      ),
    );
  }
}