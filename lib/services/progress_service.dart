import '../game_logic/models/game_progress.dart';
import 'offline_store.dart';
import 'sync_service.dart';

class ProgressService {
  final OfflineStore _store;
  final SyncService _syncService;

  ProgressService(this._store, this._syncService);

  Future<void> saveProgress(GameProgress progress) async {
    await _store.saveProgress(progress);
    // Enqueue item for sync (sync happens periodically or on network change)
    _syncService.enqueueItem(progress.sessionId, 'progress', progress.uid);
  }

  Future<GameProgress?> getProgress(String uid, String gameId) async {
    return _store.getProgress(uid, gameId);
  }
}
