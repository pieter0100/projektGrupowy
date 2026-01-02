import 'package:flutter/material.dart';
import 'package:projekt_grupowy/widgets/login_text_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  // clean controllers after closing 
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // login logic function
  void _handleEmail() {
    if (_formKey.currentState!.validate()) {
      
      final email = _emailController.text.trim();

      // businnes logic
      print("--------------------------");
      print("Próba logowania:");
      print("Email: $email");
      print("--------------------------");

      // authService.login(email, password);
      
      // message for user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logging as $email...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFFFFAF5);
    const Color primaryColor = Color(0xFFDCA466);
    const Color linkColor = Color(0xFF7CB69D);

    return Scaffold(
      appBar: AppBar(),
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
                      'Forgot',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                    ),

                    const SizedBox(height: 60),

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

                    SizedBox(height: 50,),

                    
                    // --- SEND  BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Send', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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