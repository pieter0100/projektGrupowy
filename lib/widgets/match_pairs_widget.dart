import 'package:flutter/material.dart';

class MatchPairsWidget extends StatelessWidget {
  final String textInside;

  const MatchPairsWidget(this.textInside, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFF7ED4DE), // kolor środka
        borderRadius: BorderRadius.circular(12), // zaokrąglone rogi
      ),
      child: Center(
        child: Text(
          textInside,
          style: const TextStyle(
            fontSize: 96,
            color: Colors.white, // kolor tekstu
            //fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}