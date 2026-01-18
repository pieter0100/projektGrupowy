import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class ExamTypedEndScreen extends StatelessWidget {
  final String level;

  const ExamTypedEndScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Exam Completed!",
              style: AppTextStyles.examEndTitle,
            ),

            SizedBox(height: AppSizes.examEndSpacing),

            SizedBox(
              width: AppSizes.examEndButtonWidth,
              height: AppSizes.examEndButtonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.examEndButtonBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => context.go('/level/learn?level=$level'),
                child: const Text(
                  "Back to Learn",
                  style: AppTextStyles.examEndButtonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
