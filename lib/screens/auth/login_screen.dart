import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/widgets/login_text_input.dart';
// Make sure to import your AuthService here!
import 'package:projekt_grupowy/services/auth_service.dart'; // Adjust path as needed

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 1. Initialize the AuthService and a loading state
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. Make the function async to handle the future from signIn
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // 3. Set loading to true to show the spinner
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // 4. Wrap the authentication call in a try/catch block
      try {
        await _authService.signIn(email, password);
        
        // Always check if the widget is still in the tree after an await
        if (mounted) {
          // Success! Navigate to the home screen (or wherever you want)
          context.go('/'); 
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged in successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Remove the "Exception: " prefix from your custom thrown errors
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        // 5. Ensure the loading state is turned off whether it succeeded or failed
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
                      'Learn',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Text(
                      'Multiplication',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),

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
                        // Note: Because of your strict regex in AuthService, 
                        // you might want to add a regex check here too so it fails 
                        // before even hitting Firebase, but length check is fine for now.
                        if (value.length < 6) {
                          return 'Password needs at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.go('/login/forgot');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- LOG IN BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        // 6. Disable the button if it's currently loading
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: primaryColor.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        // 7. Show a progress indicator when loading
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Log In',
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
                          "Don't have account yet? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go('/signup');
                          },
                          child: const Text(
                            "Sign Up",
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