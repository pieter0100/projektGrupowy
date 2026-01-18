import '../game_logic/models/game_result.dart';
import 'offline_store.dart';
import 'sync_service.dart';

class ResultsService {
  final OfflineStore _store;
  final SyncService _syncService;

  ResultsService(this._store, this._syncService);

  Future<void> saveResult(GameResult result) async {
    await _store.saveResult(result);
    // Enqueue item for sync (sync happens periodically or on network change)
    _syncService.enqueueItem(result.sessionId, 'result', result.uid);
  }

  Future<List<GameResult>> listUserResults(String uid, {int? limit, int? paging}) async {
    return _store.listUserResults(uid, limit: limit, paging: paging);
  }
}
