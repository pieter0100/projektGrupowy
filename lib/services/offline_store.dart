import 'package:hive/hive.dart';
import '../game_logic/models/game_result.dart';
import '../game_logic/models/game_progress.dart';

class OfflineStore {
  final Box _resultsBox;
  final Box _progressBox;

  /// Flaga blokująca zapis podczas wylogowywania
  bool _writesDisabled = false;

  OfflineStore(this._resultsBox, this._progressBox);

  ///  Włącza/wyłącza blokadę zapisu.
  /// Używane przez AppSessionController podczas sekwencji wylogowania.
  void disableWrites(bool value) {
    _writesDisabled = value;
  }

  /// Sprawdza, czy istnieją jakiekolwiek dane oczekujące na synchronizację.
  /// Używamy .any(), żeby było szybciej (przerywa przy pierwszym znalezieniu).
  bool hasPendingData() {
    final hasPendingResults = _resultsBox.values.cast<GameResult>().any(
      (result) => result.syncPending,
    );

    final hasPendingProgress = _progressBox.values.cast<GameProgress>().any(
      (progress) => progress.syncPending,
    );

    return hasPendingResults || hasPendingProgress;
  }

  /// ----------------------------------------------------------
  /// API FOR HYDRATION FROM CLOUD
  /// ----------------------------------------------------------

  Future<void> importResultFromCloud(Map<String, dynamic> data) async {
    try {
      final cloudResult = GameResult.fromMap(data);
      cloudResult.syncPending = false;

      final localResult = _resultsBox.get(cloudResult.sessionId) as GameResult?;

      if (localResult == null) {
        await _resultsBox.put(cloudResult.sessionId, cloudResult);
      } else {
        if (localResult.syncPending) {
          return; // Lokalna wersja czeka na wysyłkę, nie nadpisujemy
        }
        await _resultsBox.put(cloudResult.sessionId, cloudResult);
      }
    } catch (e) {
      print('Error importing result: $e');
    }
  }

  Future<void> importProgressFromCloud(Map<String, dynamic> data) async {
    try {
      final cloudProgress = GameProgress.fromMap(data);
      cloudProgress.syncPending = false;

      final localProgress =
          _progressBox.get(cloudProgress.sessionId) as GameProgress?;

      if (localProgress == null) {
        await _progressBox.put(cloudProgress.sessionId, cloudProgress);
      } else {
        if (localProgress.syncPending) {
          return;
        }

        final cloudTime = cloudProgress.lastUpdated;
        final localTime = localProgress.lastUpdated;

        if (cloudTime.isAfter(localTime)) {
          await _progressBox.put(cloudProgress.sessionId, cloudProgress);
        }
      }
    } catch (e) {
      print('Error importing progress: $e');
    }
  }

  Future<void> clearSensitiveData() async {
    await _resultsBox.clear();
    await _progressBox.clear();
  }

  Future<void> saveResult(GameResult result) async {
    // Sprawdzamy blokadę
    if (_writesDisabled) {
      throw Exception('Cannot save result: App is logging out.');
    }

    result.syncPending = true;
    await _resultsBox.put(result.sessionId, result);
  }

  Future<void> saveProgress(GameProgress progress) async {
    // Sprawdzamy blokadę
    if (_writesDisabled) {
      throw Exception('Cannot save progress: App is logging out.');
    }

    progress.syncPending = true;
    await _progressBox.put(progress.sessionId, progress);
  }

  Future<List<GameResult>> listUserResults(
    String uid, {
    int? limit,
    int? paging,
  }) async {
    return _resultsBox.values
        .where((r) => r.uid == uid)
        .cast<GameResult>()
        .toList();
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
}
