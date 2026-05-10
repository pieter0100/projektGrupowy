import 'package:hive/hive.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/user/user.dart' as model;
import 'package:projekt_grupowy/models/user/user_stats.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/utils/streak_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../game_logic/models/game_result.dart';
import 'offline_store.dart';
import 'sync_service.dart';
import 'achievement_service.dart';

class ResultsService {
  final OfflineStore _store;
  final SyncService _syncService;

  ResultsService(this._store, this._syncService);

  Future<void> saveLevelProgress(String uid, LevelProgress progress) async {
    try {
      // 1. Check for achievements locally
      final usersBox = Hive.box<model.User>(LocalSaves.usersBoxName);
      final user = usersBox.get(uid);
      if (user != null) {
        final newAchievements = AchievementService.checkProgressAchievements(progress, user.stats);
        if (newAchievements.length > user.stats.achievements.length) {
          final updatedStats = user.stats.copyWith(achievements: newAchievements);
          final updatedUser = model.User(
            userId: user.userId,
            profile: user.profile,
            stats: updatedStats,
          );
          await usersBox.put(uid, updatedUser);
          
          // Trigger a stats sync to Firestore immediately since achievements changed
          await _syncStatsToFirestore(uid, updatedStats);
        }
      }

      // 2. Sync progress itself
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('levelProgress')
          .doc(progress.levelId)
          .set(progress.toJson(), SetOptions(merge: true));
      print('Successfully updated Firestore level progress for user $uid');
    } catch (e) {
      print('Error updating Firestore level progress for user $uid: $e');
    }
  }

  /// Helper to sync stats to Firestore (DRY)
  Future<void> _syncStatsToFirestore(String uid, UserStats finalStats) async {
    try {
      final int totalAchievementXP = finalStats.achievements.fold(0, (sum, a) => sum + a.xpValue);
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'stats': {
          'totalGamesPlayed': finalStats.totalGamesPlayed,
          'totalPoints': totalAchievementXP,
          'currentStreak': finalStats.currentStreak,
          'lastPlayedAt': finalStats.lastPlayedAt?.toIso8601String(),
          'achievements': finalStats.achievements.map((a) => a.toJson()).toList(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error in _syncStatsToFirestore: $e');
    }
  }

  Future<void> saveResult(GameResult result) async {
    await _store.saveResult(result);
    
    // Update user streak and achievements in Hive
    await _updateUserStreakAndStats(result);
    
    // Enqueue item for sync (sync happens periodically or on network change)
    _syncService.enqueueItem(result.sessionId, 'result', result.uid);
  }

  /// Update user's streak and stats in Hive after a game result is saved
  Future<void> _updateUserStreakAndStats(GameResult result) async {
    try {
      final String uid = result.uid;
      final int score = result.score;
      final usersBox = Hive.box<model.User>(LocalSaves.usersBoxName);
      final user = usersBox.get(uid);
      
      if (user != null) {
        // Calculate new streak based on game play
        print('DEBUG: Before updateStreak - Stats: ${user.stats}');
        final updatedStats = StreakCalculator.updateStreak(user.stats, DateTime.now());
        
        // Add the game score and check achievements
        UserStats finalStats = StreakCalculator.addGameScore(updatedStats, score).copyWith(
          totalGamesPlayed: user.stats.totalGamesPlayed + 1,
        );

        // Check for new achievements
        final newAchievements = AchievementService.checkGameAchievements(result, finalStats);
        finalStats = finalStats.copyWith(achievements: newAchievements);
        
        print('DEBUG: Final Stats for Firestore: $finalStats');
        
        // Update user with new stats
        final updatedUser = model.User(
          userId: user.userId,
          profile: user.profile,
          stats: finalStats,
        );
        
        await usersBox.put(uid, updatedUser);

        // Update Firestore
        await _syncStatsToFirestore(uid, finalStats);
      }
    } catch (e) {
      // Log error but don't fail - streak calculation is best-effort
      print('Error updating streak for user ${result.uid}: $e');
    }
  }

  Future<List<GameResult>> listUserResults(String uid, {int? limit, int? paging}) async {
    return _store.listUserResults(uid, limit: limit, paging: paging);
  }

  /// Get current user streak
  int? getCurrentStreak(String uid) {
    try {
      final usersBox = Hive.box<model.User>(LocalSaves.usersBoxName);
      final user = usersBox.get(uid);
      return user?.stats.currentStreak ?? 0;
    } catch (e) {
      print('Error getting streak for user $uid: $e');
      return 0;
    }
  }

  /// Get user stats
  model.User? getUser(String uid) {
    try {
      final usersBox = Hive.box<model.User>(LocalSaves.usersBoxName);
      return usersBox.get(uid);
    } catch (e) {
      print('Error getting user $uid: $e');
      return null;
    }
  }
}
