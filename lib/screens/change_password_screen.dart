import 'package:flutter/material.dart';
import 'package:projekt_grupowy/widgets/login_text_input.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController1 = TextEditingController();
  final _passwordController2 = TextEditingController();

  // clean controllers after closing 
  @override
  void dispose() {
    _passwordController1.dispose();
    _passwordController2.dispose();
    super.dispose();
  }

  // password logic function
  void _handlePassword() {
    if (_formKey.currentState!.validate()) {
      
      final password1 = _passwordController1.text;
      final password2 = _passwordController2.text;

      // businnes logic
      print("--------------------------");
      print("Próba zmiany hasla:");
      print("Password1: $password1");
      print("Password2: $password2");
      print("--------------------------");

      // chyba cos z firebase to be removed
      if (password1 == password2) {
        
      }
      else {
        // message for user
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Passwords must be the same')));
      }
    }
  }

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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      'Change',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                    ),

                    const SizedBox(height: 60),

                    // --- PASSWORD INPUT ---
                    LoginTextInput(
                      hintText: 'New password',
                      isPassword: true,
                      controller: _passwordController1,
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

                    SizedBox(height: 30,),
                    

                    // --- REAPEAT PASSWORD INPUT ---
                    LoginTextInput(
                      hintText: 'Confirm password',
                      isPassword: true,
                      controller: _passwordController2,
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

                    SizedBox(height: 50,),
                    
                    // --- SEND  BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handlePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Update', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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