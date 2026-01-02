import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/widgets/login_text_input.dart';

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

  // clean controllers after closing
  @override
  void dispose() {
    _nickController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // sign up logic function
  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      final nick = _nickController.text;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // businnes logic
      print("--------------------------");
      print("Próba rejestracji:");
      print('Nick: $nick');
      print("Email: $email");
      print("Hasło: $password");
      print("--------------------------");

      // authService.login(email, password);

      // message for user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signing as $nick...')));
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
                        if (value.length < 6) {
                          return 'Password needs at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 50),

                    // --- LOG IN BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
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
