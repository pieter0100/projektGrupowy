import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/utils/constants.dart';

class PracticeEndScreen extends StatefulWidget {
  final String level;

  const PracticeEndScreen({super.key, required this.level});

  @override
  State<PracticeEndScreen> createState() => _PracticeEndScreenState();
}

class _PracticeEndScreenState extends State<PracticeEndScreen> {
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
    return const Scaffold(
      body: Center(
        child: Text(
          "Congratulations! \nYou answered all the questions correctly!",
          style: TextStyle(fontSize: AppSizes.fontSizeCongratulations),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
