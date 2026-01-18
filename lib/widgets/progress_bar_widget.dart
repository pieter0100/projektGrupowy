import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final double value;

  const ProgressBarWidget({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 371,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF7ED4DE),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
