import '../game_logic/models/game_progress.dart';
import 'offline_store.dart';
import 'sync_service.dart';

class ProgressService {
  final OfflineStore _store;
  final SyncService _syncService;

  ProgressService(this._store, this._syncService);

  Future<void> saveProgress(GameProgress progress) async {
    await _store.saveProgress(progress);
    await _syncService.enqueueProgress(progress);
  }

  Future<GameProgress?> getProgress(String uid, String gameId) async {
    return _store.getProgress(uid, gameId);
  }
}
