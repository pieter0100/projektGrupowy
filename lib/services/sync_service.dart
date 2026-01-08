import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  final List<Map<String, dynamic>> _errorLog = [];

  SyncService(this._store, this._firestore, this._auth);


  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(minutes: 15), (_) => syncNow());
    // Real connectivity listener: triggers sync on network change (offline→online)
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      // If any connectivity result is not 'none', trigger sync
      if (results.any((r) => r != ConnectivityResult.none)) {
        syncNow();
      }
    });
    // Requirement: periodic sync and event-based sync (connectivity)
  }

  void stop() {
    _timer?.cancel();
    _connectivitySub?.cancel();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    if (_auth.currentUser == null) return; // Requirement: sync only with active Firebase Auth session
    _isSyncing = true;
    try {
      await _syncResults();
      await _syncProgress();
      _retryCount = 0; // reset on success
    } catch (e) {
        // Exponential backoff on failure (requirement)
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
      // Per-item error logging (requirement)
      for (var result in pending) {
        errors[result.sessionId] = e.toString();
        _errorLog.add({
          'type': 'result',
          'sessionId': result.sessionId,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      rethrow;
    }
    if (errors.isNotEmpty) {
      log('Sync errors (results): $errors');
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
      // Per-item error logging (requirement)
      for (var progress in pending) {
        errors[progress.sessionId] = e.toString();
        _errorLog.add({
          'type': 'progress',
          'sessionId': progress.sessionId,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      rethrow;
    }
    if (errors.isNotEmpty) {
      log('Sync errors (progress): $errors');
    }
  }
  // Call this on sign out
  void onSignedOut() {
    stop(); // Requirement: stop immediately on sign out
  }
  // Call this on app start or profile screen entry
  void triggerSync() {
    syncNow(); // Requirement: trigger sync on app start or profile entry
  }

  // For testing or diagnostics: get error log
  List<Map<String, dynamic>> getErrorLog() => List.unmodifiable(_errorLog);
}
