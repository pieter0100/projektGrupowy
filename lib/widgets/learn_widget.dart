import 'package:flutter/material.dart';

class LearnWidget extends StatelessWidget {
  final String textInside;

  const LearnWidget(this.textInside, {Key? key}) : super(key: key);

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
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            color: Color(0xFF72BFC7),
          ),
          child: (textInside == 'intro')
              ? Center(
                child: Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 50.0,
                ),
          )
              :
          Center(
            child: (textInside == 'practice')
                ? Center(
              child: Icon(
                Icons.create,
                color: Colors.white,
                size: 50.0,
              ),
            )
                :
            Center(
              child: Icon(
                Icons.edit_document,
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

