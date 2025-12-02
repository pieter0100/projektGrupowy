import 'package:flutter/material.dart';

class LearnInfoWidget extends StatelessWidget {
  final String textInside;

  const LearnInfoWidget(this.textInside, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 211,
      height: 128,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E8E8), // background color
        border: Border.all(
          color: const Color(0xFFC4C4C4), // border color
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          textInside,
          style: const TextStyle(
            fontSize: 34,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
