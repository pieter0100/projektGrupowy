import 'package:flutter/material.dart';

class SettingsDataWidget extends StatelessWidget {
  final String textInside;

  const SettingsDataWidget(this.textInside, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 378,
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white, // kolor środka
        border: Border.all(
          color: const Color(0xFFC4C4C4), // obramowanie
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20), // zaokrąglone rogi
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle,
              color: const Color.fromARGB(255, 206, 190, 245),
              size: 35,
            ),
            const SizedBox(width: 8), // odstęp między ikoną a tekstem
            Text(
              textInside,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 130),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFFC4C4C4),
              size: 35,
            ),
          ],
        ),
      ),
    );
  }
}