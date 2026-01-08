import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  bool _isValidUsername(String username) {
    return username.trim().isNotEmpty;
  }

  Future<bool> _isUsernameTaken(String username) async {
    final query = await _firestore.collection('users').where('profile.displayName', isEqualTo: username).get();
    return query.docs.isNotEmpty;
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    final UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // Register with email, password, and optional username
  Future<User?> register(String email, String password, String username) async {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
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
  }

  // Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream of auth state changes
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();
}
