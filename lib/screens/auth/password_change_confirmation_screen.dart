import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordChangeConfirmationScreen extends StatefulWidget {
  const PasswordChangeConfirmationScreen({super.key});

  @override
  State<PasswordChangeConfirmationScreen> createState() =>
      _PasswordChangeConfirmationScreenState();
}

class _PasswordChangeConfirmationScreenState
    extends State<PasswordChangeConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFFFAF5);
    const Color primaryColor = Color(0xFFDCA466);

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Text(
                      'Updated',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 40),

                    Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFAB70DF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4.0),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/check.png',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- SEND  BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => {context.go('/login')},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),

            // --- DINOZAUR ---
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
