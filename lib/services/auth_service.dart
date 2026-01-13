import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Checks if the email format is valid (simple version)
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
    // Regex explanation:
    // r                : raw string
    // ^                : start of string
    // \S+              : one or more non-whitespace characters
    // @                : literal @
    // \S+              : one or more non-whitespace characters
    // \.               : literal dot
    // \S+              : one or more non-whitespace characters
    // $                : end of string
    return emailRegex.hasMatch(email);
  }

  // Deprecated: fetchSignInMethodsForEmail is no longer supported due to security reasons.
  // Instead, handle 'email-already-in-use' error in register method.

  
  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\-_\+=\[\]{};:\\|,.<>\/?]).{8,}$');
    // Regex explanation:
    // r                : raw string 
    // ^                : start of string
    // (?=.*[a-z])      : at least one lowercase letter
    // (?=.*[A-Z])      : at least one uppercase letter
    // (?=.*\d)         : at least one digit
    // (?=.*[!@#\$%\^&\*\-_\+=\[\]{};:\\|,.<>\/?]) : at least one special character
    // .{8,}            : at least 8 characters long
    // $                : end of string
    return passwordRegex.hasMatch(password);
  }

  bool _isValidUsername(String username) {
    return username.trim().isNotEmpty;
  }

  Future<bool> _isUsernameTaken(String username) async {
    final query = await _firestore.collection('users').where('profile.displayName', isEqualTo: username).get();
    return query.docs.isNotEmpty;
  }

  // Register with email, password, and username
  Future<User?> register(String email, String password, String username) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      throw Exception('Please enter a valid email address.');
    }
    if (!_isValidPassword(password)) {
      throw Exception('Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.');
    }
    if (!_isValidUsername(username)) {
      throw Exception('Please enter a valid username.');
    }
    if (await _isUsernameTaken(username)) {
      throw Exception('This username is already taken.');
    }
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'profile': {
            'displayName': username,
            'age': null,
          },
          'stats': {
            'totalGamesPlayed': 0,
            'totalPoints': 0,
            'currentStreak': 0,
            'lastPlayedAt': null,
          },
          'settings': {},
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // If the email is already in use, Firebase throws a FirebaseAuthException with code 'email-already-in-use'.
      // This is handled here and a user-friendly message can be provided if needed.
      throw Exception(e.message ?? 'Registration error.');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Send password reset email
  Future<void> sendPasswordReset(String email) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      throw Exception('Please enter a valid email address.');
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset error.');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }
  
  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      throw Exception('Please enter a valid email address.');
    }
    if (!_isValidPassword(password)) {
      throw Exception('Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.');
    }
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication error.');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign out error.');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Stream of auth state changes
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();
}
