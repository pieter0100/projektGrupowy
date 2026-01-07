import 'package:flutter/material.dart';

class ProfileField extends StatefulWidget {
  final String label;
  final String initialValue;

  ProfileField({super.key, required this.label, required this.initialValue});

  @override
  _ProfileFieldState createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<ProfileField> {
  final FocusNode _myFocusNode = FocusNode();

  IconData iconData = Icons.edit_outlined;

  Color fillColor = const Color(0xFFE5E5E5);

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    // controller to handle user input
    _controller = TextEditingController(text: widget.initialValue);

    // add focus node for changing icon
    _myFocusNode.addListener(() {
      setState(() {
        if (_myFocusNode.hasFocus) {
          iconData = Icons.check;
        } else {
          iconData = Icons.edit_outlined;
        }
      });
    });
  }

  @override
  void dispose() {
    // clean stuff
    _controller.dispose();
    _myFocusNode.dispose();
    super.dispose();
  }

  void handleNickChange(String value) {
    // Handle nick change logic here
    print('Nick changed to: $value');

    // update logic here TODO

    // if nick is avaible
    _myFocusNode.unfocus();
    // else TODO
  }

  void handleNameChange(String value) {
    // Handle name change logic here
    print('Name changed to: $value');

    // update logic here TODO

    // after changing name, unfocus
    _myFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              widget.label,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ),

          // TEXT FORM FIELD
          Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: TextFormField(
              focusNode: _myFocusNode,
              controller: _controller,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              readOnly: widget.label == 'Email:' ? true : false,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                suffixIcon: widget.label != 'Email:'
                    ? Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: IconButton(
                          icon: Icon(iconData, size: 24, color: Colors.black),

                          onPressed: _myFocusNode.hasFocus
                              ? () {
                                  if (widget.label == 'Nick:' &&
                                      _myFocusNode.hasFocus) {
                                    handleNickChange(_controller.text);
                                  } else {
                                    handleNameChange(_controller.text);
                                  }
                                }
                              : null,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
