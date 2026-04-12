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
          ],
        ),
      ),
    );
  }
}