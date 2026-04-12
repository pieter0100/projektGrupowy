import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/services/auth_service.dart';
import 'package:projekt_grupowy/services/offline_store.dart';
import 'package:projekt_grupowy/game_logic/models/game_result.dart';
import 'package:projekt_grupowy/game_logic/models/game_progress.dart';
import 'package:hive/hive.dart';

void main() {
  group('Account Deletion Integration Tests', () {
    late AuthService authService;
    late FirebaseAuth auth;
    late FirebaseFirestore firestore;
    late String testUid;
    late String testEmail;
    late String testPassword;

    setUpAll(() async {
      authService = AuthService();
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;

      // Use Firebase emulator for testing
      // Make sure emulator is running: firebase emulators:start
      testEmail =
          'delete-test-${DateTime.now().millisecondsSinceEpoch}@test.com';
      testPassword = 'TestPassword123!'; // Must match AuthService requirements
    });

    setUp(() async {
      // Register new test user for each test
      final user = await authService.register(
        testEmail,
        testPassword,
        'DeleteTestUser${DateTime.now().millisecondsSinceEpoch}',
      );
      testUid = user!.uid;

      // Create some test game results
      await firestore.collection('user_results').add({
        'uid': testUid,
        'sessionId': 'session-1-${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
        'score': 100,
        'gameType': 'mc',
      });

      // Create some test game progress
      await firestore.collection('game_progress').add({
        'uid': testUid,
        'sessionId': 'progress-1-${DateTime.now().millisecondsSinceEpoch}',
        'gameId': 'game-1',
        'completedCount': 5,
        'totalCount': 10,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    });

    tearDown(() async {
      // Clean up - delete any remaining test data
      // (Cloud Function should have done this, but ensure no orphaned data)
      try {
        final results = await firestore
            .collection('user_results')
            .where('uid', isEqualTo: testUid)
            .get();
        for (final doc in results.docs) {
          await doc.reference.delete();
        }

        final progress = await firestore
            .collection('game_progress')
            .where('uid', isEqualTo: testUid)
            .get();
        for (final doc in progress.docs) {
          await doc.reference.delete();
        }

        await firestore.collection('users').doc(testUid).delete();

        // Sign out if user still exists
        try {
          await auth.signOut();
        } catch (_) {}
      } catch (_) {
        // User already deleted or data already cleaned up
      }
    });

    test('Re-authentication succeeds with correct password', () async {
      // Should not throw
      await authService.reauthenticateUser(testPassword);
    });

    test('Re-authentication fails with incorrect password', () async {
      expect(
        () => authService.reauthenticateUser('WrongPassword123!'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Incorrect password'),
          ),
        ),
      );
    });

    test('Account deletion removes Firebase Auth user', () async {
      // Verify user exists
      var user = auth.currentUser;
      expect(user, isNotNull);
      expect(user!.uid, testUid);

      // Re-authenticate and delete
      await authService.reauthenticateUser(testPassword);
      await authService.deleteAccount();

      // Verify user is deleted from Auth
      // After deletion, currentUser should be null (app signed out)
      expect(auth.currentUser, isNull);
    });

    test('Account deletion removes Firestore user document', () async {
      // Verify user doc exists
      final userDoc = await firestore.collection('users').doc(testUid).get();
      expect(userDoc.exists, isTrue);

      // Delete account
      await authService.reauthenticateUser(testPassword);
      await authService.deleteAccount();

      // Wait for Cloud Function to execute (should be quick)
      await Future.delayed(const Duration(seconds: 2));

      // Verify user doc is deleted
      final deletedDoc = await firestore.collection('users').doc(testUid).get();
      expect(deletedDoc.exists, isFalse);
    });

    test('Account deletion removes all user_results documents', () async {
      // Create additional results
      await firestore.collection('user_results').add({
        'uid': testUid,
        'sessionId': 'session-2-${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
        'score': 250,
      });

      // Verify results exist
      var results = await firestore
          .collection('user_results')
          .where('uid', isEqualTo: testUid)
          .get();
      expect(results.docs.isNotEmpty, isTrue);
      final resultCount = results.docs.length;
      expect(resultCount, greaterThan(0));

      // Delete account
      await authService.reauthenticateUser(testPassword);
      await authService.deleteAccount();

      // Wait for Cloud Function
      await Future.delayed(const Duration(seconds: 2));

      // Verify all results are deleted
      results = await firestore
          .collection('user_results')
          .where('uid', isEqualTo: testUid)
          .get();
      expect(results.docs.isEmpty, isTrue);
    });

    test('Account deletion removes all game_progress documents', () async {
      // Verify progress exists
      var progress = await firestore
          .collection('game_progress')
          .where('uid', isEqualTo: testUid)
          .get();
      expect(progress.docs.isNotEmpty, isTrue);

      // Delete account
      await authService.reauthenticateUser(testPassword);
      await authService.deleteAccount();

      // Wait for Cloud Function
      await Future.delayed(const Duration(seconds: 2));

      // Verify all progress is deleted
      progress = await firestore
          .collection('game_progress')
          .where('uid', isEqualTo: testUid)
          .get();
      expect(progress.docs.isEmpty, isTrue);
    });

    test('Offline store clearAllData removes all cached data', () async {
      // Initialize Hive boxes for testing
      final resultsBox = await Hive.openBox<GameResult>('test_results');
      final progressBox = await Hive.openBox<GameProgress>('test_progress');

      try {
        final offlineStore = OfflineStore(resultsBox, progressBox);

        // Add test data
        final result = GameResult(
          sessionId: 'test-session',
          uid: testUid,
          timestamp: DateTime.now(),
          stageResults: [],
          score: 100,
          gameType: 'mc',
        );

        final progress = GameProgress(
          sessionId: 'test-session',
          uid: testUid,
          gameId: 'game-1',
          completedCount: 5,
          totalCount: 10,
          lastUpdated: DateTime.now(),
        );

        await offlineStore.saveResult(result);
        await offlineStore.saveProgress(progress);

        // Verify data exists
        expect(resultsBox.isNotEmpty, isTrue);
        expect(progressBox.isNotEmpty, isTrue);

        // Clear all data
        await offlineStore.clearAllData();

        // Verify all data is cleared
        expect(resultsBox.isEmpty, isTrue);
        expect(progressBox.isEmpty, isTrue);
      } finally {
        await resultsBox.close();
        await progressBox.close();
      }
    });

    test(
      'Offline store clearUserData removes only user-specific data',
      () async {
        final resultsBox = await Hive.openBox<GameResult>('test_results_user');
        final progressBox = await Hive.openBox<GameProgress>(
          'test_progress_user',
        );

        try {
          final offlineStore = OfflineStore(resultsBox, progressBox);

          final otherUid = 'other-user-uid';

          // Add data for current user
          final userResult = GameResult(
            sessionId: 'user-session',
            uid: testUid,
            timestamp: DateTime.now(),
            stageResults: [],
            score: 100,
            gameType: 'mc',
          );

          // Add data for other user
          final otherResult = GameResult(
            sessionId: 'other-session',
            uid: otherUid,
            timestamp: DateTime.now(),
            stageResults: [],
            score: 200,
            gameType: 'mc',
          );

          await offlineStore.saveResult(userResult);
          await offlineStore.saveResult(otherResult);

          // Verify both exist
          expect(resultsBox.length, 2);

          // Clear only test user data
          await offlineStore.clearUserData(testUid);

          // Verify only testUid data is removed, other user data remains
          expect(resultsBox.length, 1);
          final remainingResult = resultsBox.values.first as GameResult;
          expect(remainingResult.uid, otherUid);
        } finally {
          await resultsBox.close();
          await progressBox.close();
        }
      },
    );
  });
}
