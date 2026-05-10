import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class ExamTypedEndScreen extends StatefulWidget {
  final int score;
  final int level;
  final int previousBest;

  const ExamTypedEndScreen({
    super.key, 
    required this.score, 
    required this.level,
    required this.previousBest,
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
    final bool isBestScore = widget.score > widget.previousBest;
    
    // Exam mode: 100 points only if perfect score AND best score
    int totalPoints = 0;
    if (isPassed && isBestScore) {
      totalPoints = 100;
    }

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
            // Points display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.orange, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPassed
                            ? (isBestScore
                                ? 'Level Completion:'
                                : 'Already Completed:')
                            : 'Points:',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: totalPoints > 0 ? AppColors.orange : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$totalPoints pts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: totalPoints > 0
                                  ? AppColors.orange
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!isBestScore && isPassed)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'You already completed this level with ${widget.previousBest}/10',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (!isPassed)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Complete all 10 questions to earn points',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
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