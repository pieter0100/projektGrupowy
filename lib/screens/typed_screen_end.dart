import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class ExamTypedEndScreen extends StatefulWidget {
  final int score;
  final int level;

  const ExamTypedEndScreen({
    super.key, 
    required this.score, 
    required this.level
  });

  @override
  State<ExamTypedEndScreen> createState() => _ExamTypedEndScreenState();
}

class _ExamTypedEndScreenState extends State<ExamTypedEndScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/level/learn?level=${widget.level}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPassed = widget.score == 10;
    final int totalPoints = widget.score * 5; // 5 points per correct answer

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
              "${widget.score}/10 correct",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Points earned display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.orange, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Total Points: $totalPoints',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}