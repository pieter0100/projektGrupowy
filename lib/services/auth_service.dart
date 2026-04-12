import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

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
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\-_\+=\[\]{};:\\|,.<>\/?]).{8,}$',
    );
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
    final query = await _firestore
        .collection('users')
        .where('profile.displayName', isEqualTo: username)
        .get();
    return query.docs.isNotEmpty;
  }

  // Register with email, password, and username
  Future<User?> register(String email, String password, String username) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      throw Exception('Please enter a valid email address.');
    }
    if (!_isValidPassword(password)) {
      throw Exception(
        'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.',
      );
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
          'profile': {'displayName': username, 'age': null},
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
      _logger.e('FirebaseAuthException code: ${e.code}');
      _logger.e('FirebaseAuthException message: ${e.message}');
      _logger.e('Full exception: $e');
      throw Exception(e.message ?? 'Registration error. Code: ${e.code}');
    } on FirebaseException catch (e) {
      _logger.e('FirebaseException: $e');
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      _logger.e('Unexpected error: $e');
      throw Exception('An unknown error occurred: $e');
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
      throw Exception(
        'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.',
      );
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

  // Re-authenticate user with password (required for account deletion)
  Future<void> reauthenticateUser(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user currently logged in.');
    }

    if (user.email == null) {
      throw Exception('User email not found.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      _logger.i('User re-authenticated successfully for: ${user.email}');
    } on FirebaseAuthException catch (e) {
      _logger.e('Re-authentication failed: ${e.code} - ${e.message}');
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      }
      throw Exception(e.message ?? 'Re-authentication failed.');
    } on FirebaseException catch (e) {
      _logger.e('Firebase error during re-auth: $e');
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      _logger.e('Unexpected error during re-auth: $e');
      throw Exception('An unknown error occurred during re-authentication.');
    }
  }

  // Delete user account - requires re-authentication and cleans up all data
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user currently logged in.');
    }

    try {
      final uid = user.uid;
      _logger.w('=== START ACCOUNT DELETION ===');
      _logger.w('User UID: $uid');
      _logger.w('User Email: ${user.email}');

      // Step 1: Delete user document from Firestore
      _logger.i('STEP 1: Deleting user document from Firestore...');
      try {
        await _firestore.collection('users').doc(uid).delete();
        _logger.i('✓ User document deleted');
      } catch (e) {
        _logger.e('❌ Error deleting user document: $e');
        rethrow;
      }

      // Step 2: Delete all user_results
      _logger.i('STEP 2: Deleting all user_results...');
      try {
        final resultsSnapshot = await _firestore
            .collection('user_results')
            .where('uid', isEqualTo: uid)
            .get();

        if (resultsSnapshot.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var doc in resultsSnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          _logger.i(
            '✓ Deleted ${resultsSnapshot.docs.length} user_results documents',
          );
        } else {
          _logger.i('✓ No user_results to delete');
        }
      } catch (e) {
        _logger.e('❌ Error deleting user_results: $e');
        rethrow;
      }

      // Step 3: Delete all game_progress
      _logger.i('STEP 3: Deleting all game_progress...');
      try {
        final progressSnapshot = await _firestore
            .collection('game_progress')
            .where('uid', isEqualTo: uid)
            .get();

        if (progressSnapshot.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var doc in progressSnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          _logger.i(
            '✓ Deleted ${progressSnapshot.docs.length} game_progress documents',
          );
        } else {
          _logger.i('✓ No game_progress to delete');
        }
      } catch (e) {
        _logger.e('❌ Error deleting game_progress: $e');
        rethrow;
      }

      // Step 4: Delete Firebase Auth user
      _logger.i('STEP 4: Deleting Firebase Auth user...');
      try {
        await user.delete();
        _logger.i('✓ Firebase Auth user deleted successfully');
      } on FirebaseAuthException catch (e) {
        _logger.e('❌ Firebase Auth Exception:');
        _logger.e('  Code: ${e.code}');
        _logger.e('  Message: ${e.message}');
        rethrow;
      } catch (e) {
        _logger.e('❌ Unexpected error deleting auth user:');
        _logger.e('  Type: ${e.runtimeType}');
        _logger.e('  Error: $e');
        rethrow;
      }

      _logger.w('=== ACCOUNT DELETION COMPLETED SUCCESSFULLY ===');
    } on FirebaseException catch (e) {
      _logger.e('FINAL ERROR - Firebase error: ${e.message}');
      throw Exception('Failed to delete account: ${e.message}');
    } on FirebaseAuthException catch (e) {
      _logger.e('FINAL ERROR - Auth deletion failed');
      throw Exception('Account deletion error: ${e.message}');
    } catch (e) {
      _logger.e('FINAL ERROR - Unexpected error: $e');
      throw Exception('Account deletion failed: $e');
    }
  }

  // Stream of auth state changes
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();
}
