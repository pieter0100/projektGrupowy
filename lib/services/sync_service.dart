import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'offline_store.dart';

class SyncService {
  final OfflineStore _store;
  final FirebaseFirestore _firestore;
  Timer? _timer;
  bool _isSyncing = false;

  SyncService(this._store, this._firestore);


  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(minutes: 15), (_) => syncNow());
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _syncResults();
      await _syncProgress();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncResults() async {
    final pending = _store.getPendingResults();
    if (pending.isEmpty) return;
    final batch = _firestore.batch();
    for (var result in pending) {
      final ref = _firestore.collection('user_results').doc(result.sessionId);
      batch.set(ref, result.toMap(), SetOptions(merge: true));
    }
    try {
      await batch.commit();
      for (var result in pending) {
        await _store.markResultSynced(result.sessionId);
      }
    } catch (e) {
      // Log error per item if needed
      // DO NOT set syncPending = false if commit failed
      rethrow;
    }
  }

  Future<void> _syncProgress() async {
    final pending = _store.getPendingProgress();
    if (pending.isEmpty) return;
    final batch = _firestore.batch();
    for (var progress in pending) {
      final ref = _firestore.collection('game_progress').doc(progress.sessionId);
      batch.set(ref, progress.toMap(), SetOptions(merge: true));
    }
    try {
      await batch.commit();
      for (var progress in pending) {
        await _store.markProgressSynced(progress.sessionId);
      }
    } catch (e) {
      // Log error per item if needed
      // DO NOT set syncPending = false if commit failed
      rethrow;
    }
  }
}
