import 'package:flutter/material.dart';

class MatchPairsWidget extends StatelessWidget {
  final String textInside;

  const MatchPairsWidget(this.textInside, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fontSize =
        textInside.length > 2 ? 56 : 82;

    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFF7ED4DE), // background color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          textInside,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}