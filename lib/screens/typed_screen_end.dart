import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/level/learn?level=$level'),
              child: const Text("Back to Learn"),
            ),
          ],
        ),
      ),
    );
  }
}
