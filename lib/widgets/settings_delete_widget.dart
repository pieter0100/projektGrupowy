import 'package:flutter/material.dart';

class SettingsDeleteWidget extends StatelessWidget {
  final String textInside;

  const SettingsDeleteWidget(this.textInside, {Key? key}) : super(key: key);

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
      child: Align(
        alignment: Alignment.centerLeft, // wyrównanie do lewej
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Icon(
                Icons.delete, 
                color: Colors.black, 
                size: 35),
              const SizedBox(width: 8),
              Text(
                textInside,
                style: const TextStyle(
                  fontSize: 20, 
                  color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}