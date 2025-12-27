import 'package:flutter/material.dart';
import 'package:projekt_grupowy/widgets/login_text_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFFFAF5);
    const Color primaryColor = Color(0xFFDCA466);
    const Color linkColor = Color(0xFF7CB69D);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Learn',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const Text(
                    'Multiplication',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 30),

                  // login and password input
                  LoginTextInput(hintText: 'Email'),
                  
                  const SizedBox(height: 20),

                  LoginTextInput(hintText: 'Password'),
                  
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Log In', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have account yet? ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                      GestureDetector(
                        onTap: () {},
                        child: const Text("Sign Up", style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Container(
                width: double.infinity, 
                alignment: Alignment.bottomCenter, 
                child: Image.asset(
                  'assets/images/dino.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}