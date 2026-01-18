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

  Future<List<GameResult>> listUserResults(String uid, {int? limit, int? paging}) async {
    // Filters results by user uid.
    // Can extend this logic to add limiting and paging if needed.
    return _resultsBox.values.where((r) => r.uid == uid).cast<GameResult>().toList();
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
    return _resultsBox.values.where((r) => r.syncPending).cast<GameResult>().toList();
  }

  List<GameProgress> getPendingProgress() {
    return _progressBox.values.where((p) => p.syncPending).cast<GameProgress>().toList();
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
}
