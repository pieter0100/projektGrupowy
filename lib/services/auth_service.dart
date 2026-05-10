import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/models/user/user.dart';
import 'package:projekt_grupowy/models/user/user_profile.dart';
import 'package:projekt_grupowy/models/user/user_stats.dart';
import 'package:logger/logger.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
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
    try {
      final query = await _firestore
          .collection('users')
          .where('profile.displayName', isEqualTo: username)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      // Because of Firestore rules, reading users collection before authentication 
      // throws a permission-denied error. We bypass this check for now.
      _logger.w('Could not check if username is taken due to permissions: $e');
      return false;
    }
  }

  // Register with email, password, and username
  Future<firebase_auth.User?> register(String email, String password, String username) async {
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
      final firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user != null) {
        // Create user profile object
        final userProfile = UserProfile(
          displayName: username,
          age: 0,
          nick: username,
        );

        // Create user stats
        final userStats = UserStats(
          totalGamesPlayed: 0,
          totalPoints: 0,
          currentStreak: 0,
          lastPlayedAt: DateTime.now(),
          achievements: [],
        );

        // Create user object
        final newUser = User(
          userId: user.uid,
          profile: userProfile,
          stats: userStats,
        );

        // Save to Hive
        await LocalSaves.saveUser(newUser);

        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'profile': {'displayName': username, 'age': 0, 'nick': username},
          'stats': {
            'totalGamesPlayed': 0,
            'totalPoints': 0,
            'currentStreak': 0,
            'lastPlayedAt': DateTime.now().toIso8601String(),
            'achievements': [],
          },
          'settings': {},
        });
      }
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // If the email is already in use, Firebase throws a FirebaseAuthException with code 'email-already-in-use'.
      // This is handled here and a user-friendly message can be provided if needed.
      _logger.e('FirebaseAuthException code: ${e.code}');
      _logger.e('FirebaseAuthException message: ${e.message}');
      _logger.e('Full exception: $e');
      throw Exception(e.message ?? 'Registration error. Code: ${e.code}');
    } on firebase_auth.FirebaseException catch (e) {
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
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset error.');
    } on firebase_auth.FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Sign in with email and password
  Future<firebase_auth.User?> signIn(String email, String password) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      throw Exception('Please enter a valid email address.');
    }
    try {
      final firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = result.user;
      if (user != null) {
        // Fetch user profile from Firestore and sync to Hive
        await syncUserFromFirestore(user.uid);
      }
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication error.');
    } on firebase_auth.FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Sync user data from Firestore to Hive
  Future<void> syncUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Extract profile data
        final profileData = data['profile'] as Map<String, dynamic>? ?? {};
        final statsData = data['stats'] as Map<String, dynamic>? ?? {};
        
        final userProfile = UserProfile(
          displayName: profileData['displayName'] as String?,
          age: profileData['age'] as int? ?? 0,
          nick: profileData['nick'] as String? ?? 'unknown',
        );
        
        final userStats = UserStats(
          totalGamesPlayed: statsData['totalGamesPlayed'] as int? ?? 0,
          totalPoints: statsData['totalPoints'] as int? ?? 0,
          currentStreak: statsData['currentStreak'] as int? ?? 0,
          lastPlayedAt: statsData['lastPlayedAt'] != null
              ? DateTime.parse(statsData['lastPlayedAt'] as String)
              : DateTime.now(),
        );
        
        final userObj = User(
          userId: uid,
          profile: userProfile,
          stats: userStats,
        );
        
        // Save to Hive
        await LocalSaves.saveUser(userObj);

        // Sync LevelProgress
        try {
          final progressSnapshot = await _firestore
              .collection('users')
              .doc(uid)
              .collection('levelProgress')
              .get();

          for (final doc in progressSnapshot.docs) {
            final data = doc.data();
            final progress = LevelProgress.fromJson(data);
            await LocalSaves.saveLevelProgress(uid, progress);
          }
        } catch (e) {
          _logger.e('Error syncing levelProgress from Firestore: $e');
        }
      }
    } catch (e) {
      _logger.e('Error syncing user from Firestore: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign out error.');
    } on firebase_auth.FirebaseException catch (e) {
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
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      _logger.i('User re-authenticated successfully for: ${user.email}');
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logger.e('Re-authentication failed: ${e.code} - ${e.message}');
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      }
      throw Exception(e.message ?? 'Re-authentication failed.');
    } on firebase_auth.FirebaseException catch (e) {
      _logger.e('Firebase error during re-auth: $e');
      throw Exception(e.message ?? 'Firebase error.');
    } catch (e) {
      _logger.e('Unexpected error during re-auth: $e');
      throw Exception('An unknown error occurred during re-authentication.');
    }
  }

  // Delete user account - direct client-side deletion (no Cloud Functions required)
  Future<void> deleteAccount(dynamic syncService) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user currently logged in.');
    }

    try {
      final uid = user.uid;
      _logger.w('=== START DIRECT ACCOUNT DELETION ===');

      // 1. Delete user results from Firestore
      _logger.i('Deleting user results...');
      final results = await _firestore.collection('user_results').where('uid', isEqualTo: uid).get();
      for (var doc in results.docs) {
        await doc.reference.delete();
      }

      // 2. Delete game progress from Firestore
      _logger.i('Deleting game progress...');
      final progress = await _firestore.collection('game_progress').where('uid', isEqualTo: uid).get();
      for (var doc in progress.docs) {
        await doc.reference.delete();
      }

      // 3. Delete user profile and its subcollections
      _logger.i('Deleting user profile and subcollections...');
      // Note: In client SDK, we must delete subcollections manually
      final levelProgress = await _firestore.collection('users').doc(uid).collection('levelProgress').get();
      for (var doc in levelProgress.docs) {
        await doc.reference.delete();
      }
      await _firestore.collection('users').doc(uid).delete();

      // 4. Delete Firebase Auth account
      _logger.i('Deleting Auth account...');
      try {
        await user.delete();
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw Exception('Account deletion requires a recent login. Please sign out and sign in again before deleting your account for security reasons.');
        }
        rethrow;
      }

      // 5. Clear local data
      await LocalSaves.clearSession();
      
      _logger.w('=== ACCOUNT DELETION COMPLETED SUCCESSFULLY ===');
    } catch (e) {
      _logger.e('FINAL ERROR - Account deletion failed: $e');
      throw Exception('Account deletion failed: $e');
    }
  }

  // Stream of auth state changes
  Stream<firebase_auth.User?> get onAuthStateChanged => _auth.authStateChanges();
}
