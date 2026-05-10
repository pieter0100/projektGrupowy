import 'package:hive/hive.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/user/user.dart' as model;
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/utils/streak_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../game_logic/models/game_result.dart';
import 'offline_store.dart';
import 'sync_service.dart';

class ResultsService {
  final OfflineStore _store;
  final SyncService _syncService;

  ResultsService(this._store, this._syncService);

  Future<void> saveLevelProgress(String uid, LevelProgress progress) async {
    try {
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

  Future<void> saveResult(GameResult result) async {
    await _store.saveResult(result);
    
    // Update user streak in Hive
    await _updateUserStreakAndStats(result.uid, result.score);
    
    // Enqueue item for sync (sync happens periodically or on network change)
    _syncService.enqueueItem(result.sessionId, 'result', result.uid);
  }

  /// Update user's streak and stats in Hive after a game result is saved
  Future<void> _updateUserStreakAndStats(String uid, int score) async {
    try {
      final usersBox = Hive.box<model.User>(LocalSaves.usersBoxName);
      final user = usersBox.get(uid);
      
      if (user != null) {
        // Calculate new streak based on game play
        final updatedStats = StreakCalculator.updateStreak(user.stats, DateTime.now());
        
        // Add the game score
        final finalStats = StreakCalculator.addGameScore(updatedStats, score);
        
        // Update user with new stats
        final updatedUser = model.User(
          userId: user.userId,
          profile: user.profile,
          stats: finalStats,
        );
        
        await usersBox.put(uid, updatedUser);

        // Update Firestore to sync stats to cloud (replaces missing Cloud Functions)
        try {
          print('Attempting to update Firestore for user $uid');
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'stats': {
              'totalGamesPlayed': finalStats.totalGamesPlayed,
              'totalPoints': finalStats.totalPoints,
              'currentStreak': finalStats.currentStreak,
              'lastPlayedAt': finalStats.lastPlayedAt?.toIso8601String(),
            }
          }, SetOptions(merge: true));
          print('Successfully updated Firestore for user $uid');
        } catch (fsError) {
          print('Error updating Firestore stats for user $uid: $fsError');
        }
      }
    } catch (e) {
      // Log error but don't fail - streak calculation is best-effort
      print('Error updating streak for user $uid: $e');
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
