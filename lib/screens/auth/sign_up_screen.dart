import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/widgets/login_text_input.dart';
import 'package:projekt_grupowy/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nickController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // AuthService instance and loading state
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // clean controllers after closing
  @override
  void dispose() {
    _nickController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // sign up logic function
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final nick = _nickController.text;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      try {
        // Call AuthService.register() with email, password, and nick (username)
        await _authService.register(email, password, nick);

        if (mounted) {
          // Success! Navigate to home screen
          context.go('/');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Log the full error to console for debugging
          log('❌ Sign up error: $e');

          // Remove the "Exception: " prefix from custom thrown errors
          final errorMessage = e.toString().replaceAll('Exception: ', '');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        // Ensure the loading state is turned off whether it succeeded or failed
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- NICK INPUT ---
                    LoginTextInput(
                      hintText: 'Nick',
                      controller: _nickController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Write Nick';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- EMAIL INPUT ---
                    LoginTextInput(
                      hintText: 'Email',
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Write Email';
                        }
                        if (!value.contains('@')) {
                          return 'Wrong email format';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- PASSWORD INPUT ---
                    LoginTextInput(
                      hintText: 'Password',
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Write password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!value.contains(RegExp(r'[a-z]'))) {
                          return 'Password must include lowercase letters';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Password must include uppercase letters';
                        }
                        if (!value.contains(RegExp(r'\d'))) {
                          return 'Password must include at least one number';
                        }
                        if (!value.contains(
                          RegExp(r'[!@#\$%\^&\*\-_\+=\[\]{};:\\|,.<>\/?]'),
                        )) {
                          return 'Password must include a special character (!@#\$%^&*-_+=\\[\\]{};:|,.<>/?\\)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 50),

                    // --- SIGN UP BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "You already have an account? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: linkColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  'assets/images/dragon1.png',
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
