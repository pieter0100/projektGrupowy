import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'offline_store.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SyncService {
  final OfflineStore _store;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  Timer? _timer;
  bool _isSyncing = false;
  int _retryCount = 0;
  static const int _maxBackoffSeconds = 300;
  StreamSubscription? _connectivitySub;

  SyncService(this._store, this._firestore, this._auth);


  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(minutes: 15), (_) => syncNow());
    // TODO: Replace with real connectivity listener
    // Example: Connectivity().onConnectivityChanged.listen((result) { if (result != ConnectivityResult.none) syncNow(); });
    // _connectivitySub = connectivityStream.listen((online) { if (online) syncNow(); });
  }

  void stop() {
    _timer?.cancel();
    _connectivitySub?.cancel();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    if (_auth.currentUser == null) return;
    _isSyncing = true;
    try {
      await _syncResults();
      await _syncProgress();
      _retryCount = 0; // reset on success
    } catch (e) {
      // Exponential backoff on failure
      _retryCount++;
      final backoff = (_retryCount <= 8)
          ? (1 << (_retryCount - 1))
          : _maxBackoffSeconds;
      Future.delayed(Duration(seconds: backoff), syncNow);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncResults() async {
    final pending = _store.getPendingResults();
    if (pending.isEmpty) return;
    final batch = _firestore.batch();
    final errors = <String, dynamic>{};
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
      // Per-item error logging (simulate, since Firestore batch errors are not per-item)
      for (var result in pending) {
        errors[result.sessionId] = e.toString();
      }
      // TODO: Persist errors in local log if needed
      rethrow;
    }
    if (errors.isNotEmpty) {
      print('Sync errors (results): $errors');
    }
  }

  Future<void> _syncProgress() async {
    final pending = _store.getPendingProgress();
    if (pending.isEmpty) return;
    final batch = _firestore.batch();
    final errors = <String, dynamic>{};
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
      // Per-item error logging (simulate, since Firestore batch errors are not per-item)
      for (var progress in pending) {
        errors[progress.sessionId] = e.toString();
      }
      // TODO: Persist errors in local log if needed
      rethrow;
    }
    if (errors.isNotEmpty) {
      print('Sync errors (progress): $errors');
    }
  }
  // Call this on sign out
  void onSignedOut() {
    stop();
  }
  // Call this on app start or profile screen entry
  void triggerSync() {
    syncNow();
  }
}
