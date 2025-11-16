import 'package:flutter/material.dart';

class LearnInfoWidget extends StatelessWidget {
  final String textInside;

  const LearnInfoWidget(this.textInside, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 211,
      height: 128,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E8E8), // kolor środka
        border: Border.all(
          color: const Color(0xFFC4C4C4), // obramowanie
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10), // zaokrąglone rogi
      ),
      child: Center(
        child: Text(
          textInside,
          style: const TextStyle(
            fontSize: 34,
            color: Colors.black, // kolor tekstu
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}