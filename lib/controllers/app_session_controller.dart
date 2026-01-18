import 'dart:async';
import 'dart:developer';
import 'dart:io'; // Needed for simple connectivity check
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';

// Importy Twoich serwisów
import '../services/sync_service.dart';
import '../services/offline_store.dart';

/// Stany sesji użytkownika
enum SessionState {
  unauthenticated, // Użytkownik niezalogowany
  bootstrapping, // Trwa pobieranie danych
  authenticated, // Zalogowany
  loggingOut, // [NOWY STAN] Trwa procedura wylogowania (sync)
}

class AppSessionController extends ChangeNotifier with WidgetsBindingObserver {
  final FirebaseAuth _auth;
  final SyncService syncService;
  final OfflineStore store;

  SessionState _state = SessionState.unauthenticated;
  StreamSubscription<User?>? _authSubscription;

  AppSessionController._(this._auth, this.syncService, this.store) {
    WidgetsBinding.instance.addObserver(this);
  }

  static Future<AppSessionController> create() async {
    log('Initializing AppSessionController dependencies...');

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // 1. INTEGRACJA Z HIVE
    final progressBox = Hive.box<LevelProgress>(
      LocalSaves.levelProgressBoxName,
    );
    final resultsBox = await Hive.openBox('game_results_sync');
    final queueBox = await Hive.openBox('sync_queue');

    // 2. WSTRZYKIWANIE ZALEŻNOŚCI
    final store = OfflineStore(resultsBox, progressBox);
    final syncService = SyncService(store, firestore, auth, queueBox);

    final controller = AppSessionController._(auth, syncService, store);
    controller._initialize();

    return controller;
  }

  void _initialize() {
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  SessionState get state => _state;

  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      log('Auth state: User logged out');
      _state = SessionState.unauthenticated;

      // Stop service if it hasn't been stopped yet (fallback)
      syncService.stop();

      // UWAGA: Zgodnie ze specyfikacją NIE CZYŚCIMY tutaj danych (clearSensitiveData).
      // Dane "pending" muszą zostać w Hive do następnego logowania.
      notifyListeners();
    } else {
      log('Auth state: User logged in (${user.uid})');
      _state = SessionState.bootstrapping;
      notifyListeners();

      // Enable writes again in case they were blocked
      store.disableWrites(false);

      await syncService.start();
      await syncService.bootstrapAfterLogin();

      _state = SessionState.authenticated;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _state == SessionState.authenticated) {
      log('App Resumed: Triggering sync check...');
      syncService.triggerSync();
    }
  }

  /// ---------------------------------------------------------------------
  /// UPDATED LOGOUT SEQUENCE
  /// ---------------------------------------------------------------------
  Future<void> signOut() async {
    log('Initiating Logout Sequence...');

    // 1. Block new data writes immediately
    // (Zakładam, że OfflineStore ma metodę flagującą, żeby UI nie dodawało nowych wyników)
    store.disableWrites(true);
    _state = SessionState.loggingOut;
    notifyListeners();

    try {
      // 2. Check for existence of records marked as sync_pending
      final bool hasPendingData = store.hasPendingData(); // Implement in Store

      if (hasPendingData) {
        // 3. Check connectivity (Simple lookup)
        bool isOnline = false;
        try {
          final result = await InternetAddress.lookup('google.com');
          isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } catch (_) {
          isOnline = false;
        }

        if (isOnline) {
          log('Logout: Pending data found and Online. Attempting Sync...');
          try {
            // 4. Call SyncNow with timeout (3 seconds max)
            await syncService.syncNow(
              reason: 'logout',
              timeout: const Duration(seconds: 3),
            );
            log('Logout: Sync completed successfully.');
          } catch (e) {
            log(
              'Logout: Sync failed or timed out. Proceeding anyway. Error: $e',
            );
          }
        } else {
          log('Logout: Pending data found but OFFLINE. Skipping sync.');
        }
      } else {
        log('Logout: No pending data. Skipping sync.');
      }
    } catch (e) {
      log('Logout: Unexpected error during pre-signout checks: $e');
    } finally {
      // 5. Stop SyncService (regardless of the result)
      syncService.stop();

      // 6. Sign out from Firebase (This triggers the listener)
      await _auth.signOut();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    syncService.stop();
    super.dispose();
  }
}
