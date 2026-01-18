import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'offline_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sync/sync_queue_item.dart';

class SyncService {
  final OfflineStore _store;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  Timer? _timer;
  bool _isSyncing = false;
  int _retryCount = 0;
  static const int _maxBackoffSeconds = 300;
  static const int _batchSize = 50;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  final List<Map<String, dynamic>> _errorLog = [];
  final Queue<SyncQueueItem> _syncQueue = Queue<SyncQueueItem>();
  Box? _queueBox;

  SyncService(this._store, this._firestore, this._auth, [this._queueBox]);


  Future<void> start() async {
    // Initialize queue persistence
    await _initQueuePersistence();
    
    _timer?.cancel();
    _timer = Timer.periodic(Duration(minutes: 15), (_) => processQueue());
    // Real connectivity listener: triggers sync on network change (offline→online)
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      // If any connectivity result is not 'none', trigger sync
      if (results.any((r) => r != ConnectivityResult.none)) {
        processQueue();
      }
    });
    // Requirement: periodic sync and event-based sync (connectivity)
  }

  void stop() {
    _timer?.cancel();
    _connectivitySub?.cancel();
  }

  // Initialize queue persistence across app restarts
  Future<void> _initQueuePersistence() async {
    _queueBox ??= await Hive.openBox('sync_queue');
    // Load existing queue from persistence
    final persistedQueue = _queueBox?.get('queue', defaultValue: <dynamic>[]) as List<dynamic>;
    for (var item in persistedQueue) {
      if (item is Map<String, dynamic>) {
        _syncQueue.add(SyncQueueItem.fromMap(item));
      }
    }
  }

  // Persist queue to Hive
  Future<void> _persistQueue() async {
    final queueList = _syncQueue.map((item) => item.toMap()).toList();
    await _queueBox?.put('queue', queueList);
  }

  // Process queue in batches (called periodically or on network change)
  Future<void> processQueue() async {
    if (_isSyncing) return;
    if (_auth.currentUser == null) return; // Requirement: sync only with active Firebase Auth session
    _isSyncing = true;
    try {
      // Process up to _batchSize items from queue
      int processed = 0;
      while (_syncQueue.isNotEmpty && processed < _batchSize) {
        final item = _syncQueue.removeFirst();
        await _syncItem(item);
        processed++;
      }
      // Persist updated queue
      await _persistQueue();
      _retryCount = 0; // reset on success
    } catch (e) {
      // Exponential backoff on failure (requirement)
      _retryCount++;
      final backoff = (_retryCount <= 8)
          ? (1 << (_retryCount - 1))
          : _maxBackoffSeconds;
      Future.delayed(Duration(seconds: backoff), processQueue);
    } finally {
      _isSyncing = false;
    }
  }

  // Sync a single queue item
  Future<void> _syncItem(SyncQueueItem item) async {
    if (item.type == 'result') {
      final result = _store.getPendingResults().where((r) => r.sessionId == item.sessionId).firstOrNull;
      if (result != null) {
        await _syncSingleResult(result);
      }
    } else if (item.type == 'progress') {
      final progress = _store.getPendingProgress().where((p) => p.sessionId == item.sessionId).firstOrNull;
      if (progress != null) {
        await _syncSingleProgress(progress);
      }
    }
  }

  // Legacy method for compatibility (now calls processQueue)
  Future<void> syncNow() async {
    await processQueue();
  }

  // Sync a single result (called from processQueue)
  Future<void> _syncSingleResult(dynamic result) async {
    final ref = _firestore.collection('user_results').doc(result.sessionId);
    try {
      // Deduplication: check if document exists before adding
      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set(result.toMap(), SetOptions(merge: true));
      }
      await _store.markResultSynced(result.sessionId);
    } catch (e) {
      // Per-item error logging (requirement)
      _errorLog.add({
        'type': 'result',
        'sessionId': result.sessionId,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      log('Sync error (result ${result.sessionId}): $e');
      rethrow;
    }
  }

  // Sync a single progress (called from processQueue)
  Future<void> _syncSingleProgress(dynamic progress) async {
    final ref = _firestore.collection('game_progress').doc(progress.sessionId);
    try {
      final doc = await ref.get();
      // Conflict resolution: only sync if local lastUpdated is newer
      if (doc.exists) {
        final remote = doc.data();
        if (remote != null && remote['lastUpdated'] != null) {
          final remoteLastUpdated = DateTime.tryParse(remote['lastUpdated'].toString());
          if (remoteLastUpdated != null && progress.lastUpdated.isBefore(remoteLastUpdated)) {
            // Local is older, skip sync
            return;
          }
        }
      }
      await ref.set(progress.toMap(), SetOptions(merge: true));
      await _store.markProgressSynced(progress.sessionId);
    } catch (e) {
      // Per-item error logging (requirement)
      _errorLog.add({
        'type': 'progress',
        'sessionId': progress.sessionId,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      log('Sync error (progress ${progress.sessionId}): $e');
      rethrow;
    }
  }
  // Enqueue a specific item for sync (called after local save)
  Future<void> enqueueItem(String sessionId, String type, String uid) async {
    final item = SyncQueueItem(
      sessionId: sessionId,
      type: type,
      uid: uid,
      enqueuedAt: DateTime.now(),
    );
    _syncQueue.add(item);
    await _persistQueue();
    // Note: actual sync happens periodically or on network change, not immediately
  }

  // Call this on sign out
  void onSignedOut() {
    stop(); // Requirement: stop immediately on sign out
  }
  
  // Call this on app start or profile screen entry
  Future<void> triggerSync() async {
    await processQueue(); // Process existing queue, not sync everything immediately
  }

  // For testing or diagnostics: get error log
  List<Map<String, dynamic>> getErrorLog() => List.unmodifiable(_errorLog);
  
  // For testing or diagnostics: get queue
  List<SyncQueueItem> getQueue() => List.unmodifiable(_syncQueue);
}
