import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {

  const ProgressBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 371,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}