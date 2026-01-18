import 'package:hive/hive.dart';
import '../game_logic/models/game_result.dart';
import '../game_logic/models/game_progress.dart';

class OfflineStore {
  final Box _resultsBox;
  final Box _progressBox;

  OfflineStore(this._resultsBox, this._progressBox);

  /// ----------------------------------------------------------
  /// API FOR HYDRATION FROM CLOUD
  /// ----------------------------------------------------------

  /// Importuje wynik gry pobrany z Firestore.
  /// Wykonuje deduplikację i sprawdza, czy nie nadpisujemy danych oczekujących na wysyłkę.
  Future<void> importResultFromCloud(Map<String, dynamic> data) async {
    try {
      // 1. Deserializacja
      final cloudResult = GameResult.fromMap(data);

      // 2. Oznaczenie jako zsynchronizowany (bo pochodzi z chmury)
      cloudResult.syncPending = false;

      // 3. Sprawdzenie co mamy lokalnie
      final localResult = _resultsBox.get(cloudResult.sessionId) as GameResult?;

      if (localResult == null) {
        // Scenariusz A: Nie mamy tego w ogóle -> Zapisz
        await _resultsBox.put(cloudResult.sessionId, cloudResult);
      } else {
        // Scenariusz B: Mamy to już lokalnie -> Sprawdź konflikt
        if (localResult.syncPending) {
          // WAŻNE: Lokalna wersja czeka na wysyłkę. NIE NADPISUJEMY JEJ.
          // Użytkownik mógł edytować coś offline, chmura ma starą wersję.
          return;
        }

        // Tutaj opcjonalnie można sprawdzić timestampy, ale GameResult jest zazwyczaj
        // niemutowalny (raz zagrana gra się nie zmienia).
        // Dla pewności można nadpisać, jeśli dane z chmury są "bogatsze" lub po prostu zostawić lokalne.
        // W tym przypadku zakładam, że chmura jest źródłem prawdy dla starych wyników.
        await _resultsBox.put(cloudResult.sessionId, cloudResult);
      }
    } catch (e) {
      // Logowanie błędu parsowania, żeby jeden błędny rekord nie wywalił całego procesu
      print('Error importing result: $e');
    }
  }

  /// Importuje postęp gry z Firestore.
  /// Zawiera logikę porównywania daty aktualizacji (Last Write Wins).
  Future<void> importProgressFromCloud(Map<String, dynamic> data) async {
    try {
      final cloudProgress = GameProgress.fromMap(data);
      cloudProgress.syncPending = false;

      final localProgress =
          _progressBox.get(cloudProgress.sessionId) as GameProgress?;

      if (localProgress == null) {
        await _progressBox.put(cloudProgress.sessionId, cloudProgress);
      } else {
        // Konflikt: Mamy wersję lokalną i wersję z chmury.

        if (localProgress.syncPending) {
          // Lokalna jest nowsza i czeka na wysyłkę - ignorujemy chmurę.
          return;
        }

        // Obie wersje są "czyste". Sprawdzamy, która jest nowsza.
        // Zakładam, że model GameProgress ma pole `lastUpdated` typu DateTime.
        final cloudTime = cloudProgress.lastUpdated;
        final localTime = localProgress.lastUpdated;

        if (cloudTime.isAfter(localTime)) {
          // Chmura ma nowszy zapis (np. z innego urządzenia) -> Nadpisujemy
          await _progressBox.put(cloudProgress.sessionId, cloudProgress);
        }
        // W przeciwnym razie (lokalny nowszy lub taki sam) -> Nic nie robimy (Deduplikacja)
      }
    } catch (e) {
      print('Error importing progress: $e');
    }
  }

  Future<void> clearSensitiveData() async {
    // Opcja A: Czyścimy wszystko (najbezpieczniej)
    await _resultsBox.clear();
    await _progressBox.clear();
  }

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
}
