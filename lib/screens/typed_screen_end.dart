import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class ExamTypedEndScreen extends StatelessWidget {
  final int score;
  final int level;

  const ExamTypedEndScreen({super.key, required this.score, required this.level});

  @override
  Widget build(BuildContext context) {
    final bool isPassed = score == 10;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPassed ? "PASSED!" : "FAILED",
              style: AppTextStyles.examEndTitle.copyWith(
                color: isPassed ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "$score/10 correct",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.examEndButtonBackground,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () => context.go('/level/learn?level=$level'),
              child: const Text("Continue", style: AppTextStyles.examEndButtonText),
            ),
          ],
        ),
      ),
    );
  }
}