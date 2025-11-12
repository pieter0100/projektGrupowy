import 'package:flutter/material.dart';

class LevelWidget extends StatelessWidget {
  final String textInside;

  const LevelWidget(this.textInside, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFFC4C4C4), width: 10)
      ),
      width: 140,
      height: 140,
      child: Center(
        // child: Text(textInside),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            color: Color(0xFF72BFC7),
          ),
          child: Center(
            child: Text(
              textInside,
              style: TextStyle(
                fontFamily: 'Roboto',
                // fontWeight: FontWeight.bold,
                fontSize: 40.0,
                color: Colors.white 
              ),),
          ),
        ),
      ),
    );
  }
}

