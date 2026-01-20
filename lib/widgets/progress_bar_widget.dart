import 'package:flutter/material.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class ProgressBarWidget extends StatelessWidget {
  final double value;

  const ProgressBarWidget({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.progressWidth,
      height: AppSizes.progressHeight,
      decoration: BoxDecoration(
        color: AppColors.progressBackground,
        borderRadius: BorderRadius.circular(AppSizes.progressRadius),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.progressFill,
                borderRadius: BorderRadius.circular(AppSizes.progressRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
