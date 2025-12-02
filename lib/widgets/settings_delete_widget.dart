import 'package:flutter/material.dart';

class SettingsDeleteWidget extends StatelessWidget {
  final String textInside;

  const SettingsDeleteWidget(this.textInside, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 378,
      height: 69,
      decoration: BoxDecoration(
        color: Colors.white, // background color
        border: Border.all(
          color: const Color(0xFFC4C4C4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
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