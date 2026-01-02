import 'package:flutter/material.dart';

class LoginTextInput extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final String? Function(String?)? validator; 
  final TextEditingController? controller;

  const LoginTextInput({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.validator, 
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(50), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller, 
        validator: validator,   
        obscureText: isPassword,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400], 
            fontWeight: FontWeight.bold, 
            fontSize: 16,
          ),
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20, 
            horizontal: 30, 
          ),
        ),
      ),
    );
  }
}