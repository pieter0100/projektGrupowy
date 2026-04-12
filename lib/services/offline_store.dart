import 'package:hive/hive.dart';
import '../game_logic/models/game_result.dart';
import '../game_logic/models/game_progress.dart';

class OfflineStore {
  final Box _resultsBox;
  final Box _progressBox;

  OfflineStore(this._resultsBox, this._progressBox);

  Future<void> saveResult(GameResult result) async {
    result.syncPending = true;
    await _resultsBox.put(result.sessionId, result);
  }

  Future<List<GameResult>> listUserResults(
    String uid, {
    int? limit,
    int? paging,
  }) async {
    // Filters results by user uid.
    // Can extend this logic to add limiting and paging if needed.
    return _resultsBox.values
        .where((r) => r.uid == uid)
        .cast<GameResult>()
        .toList();
  }

  Future<void> saveProgress(GameProgress progress) async {
    progress.syncPending = true;
    await _progressBox.put(progress.sessionId, progress);
  }

  Future<GameProgress?> getProgress(String uid, String gameId) async {
    return _progressBox.values
        .where((p) => p.uid == uid && p.gameId == gameId)
        .cast<GameProgress>()
        .firstOrNull;
  }

  List<GameResult> getPendingResults() {
    return _resultsBox.values
        .where((r) => r.syncPending)
        .cast<GameResult>()
        .toList();
  }

  List<GameProgress> getPendingProgress() {
    return _progressBox.values
        .where((p) => p.syncPending)
        .cast<GameProgress>()
        .toList();
  }

  Future<void> markResultSynced(String sessionId) async {
    final result = _resultsBox.get(sessionId);
    if (result != null) {
      result.syncPending = false;
      await _resultsBox.put(sessionId, result);
    }
  }

  Future<void> markProgressSynced(String sessionId) async {
    final progress = _progressBox.get(sessionId);
    if (progress != null) {
      progress.syncPending = false;
      await _progressBox.put(sessionId, progress);
    }
  }

  /// Clear all cached data for a specific user
  /// Called when user account is deleted to remove local data
  Future<void> clearUserData(String uid) async {
    // Remove all user_results for this uid
    final resultKeys = _resultsBox.keys.where((key) {
      final result = _resultsBox.get(key) as GameResult?;
      return result?.uid == uid;
    }).toList();

    for (final key in resultKeys) {
      await _resultsBox.delete(key);
    }

    // Remove all game_progress for this uid
    final progressKeys = _progressBox.keys.where((key) {
      final progress = _progressBox.get(key) as GameProgress?;
      return progress?.uid == uid;
    }).toList();

    for (final key in progressKeys) {
      await _progressBox.delete(key);
    }
  }

  /// Clear all data from offline cache
  /// Use with caution - called during full reset or debugging
  Future<void> clearAllData() async {
    await _resultsBox.clear();
    await _progressBox.clear();
  }
}
