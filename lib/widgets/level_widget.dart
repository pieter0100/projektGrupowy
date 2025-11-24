import 'package:flutter/material.dart';

class LevelWidget extends StatelessWidget {
  final String textInside;
  final bool lock;

  const LevelWidget({
    required this.textInside,
    required this.lock,
    super.key,                
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFFC4C4C4), width: 10),
      ),
      width: 140,
      height: 140,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            color: Color(0xFF72BFC7),
          ),
          child: (textInside == 'lock')
              ? Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Icon(Icons.lock, color: Colors.black, size: 50.0),
                  ),
                )
              : Center(
                  child: Text(
                    textInside,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      // fontWeight: FontWeight.bold,
                      fontSize: 40.0,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
