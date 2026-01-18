import 'dart:async';
import 'dart:developer';
import 'dart:io'; // Potrzebne do sprawdzania połączenia internetowego
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// Modele i stałe
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';

// Serwisy
import '../services/sync_service.dart';
import '../services/offline_store.dart';

/// Stany sesji użytkownika
enum SessionState {
  unauthenticated, // Użytkownik niezalogowany
  bootstrapping,   // Trwa pobieranie danych po zalogowaniu
  authenticated,   // Zalogowany i gotowy do działania
  loggingOut,      // Trwa procedura wylogowania (synchronizacja)
}

/// Typ zdarzenia odświeżenia danych (dla UI)
enum DataRefreshEvent {
  bootstrapCompleted, // Pobieranie wstępne zakończone
  syncCompleted,      // Synchronizacja w tle zakończona (opcjonalne)
}

class AppSessionController extends ChangeNotifier with WidgetsBindingObserver {
  final FirebaseAuth _auth;
  final SyncService syncService;
  final OfflineStore store;

  SessionState _state = SessionState.unauthenticated;
  StreamSubscription<User?>? _authSubscription;

  // Stream do powiadamiania UI o nowych danych (np. po bootstrapie)
  // Używamy .broadcast(), aby wiele widgetów mogło nasłuchiwać jednocześnie.
  final _refreshController = StreamController<DataRefreshEvent>.broadcast();

  /// Getter strumienia dla widgetów UI (np. LevelScreen)
  Stream<DataRefreshEvent> get onDataRefreshed => _refreshController.stream;

  /// Prywatny konstruktor
  AppSessionController._(this._auth, this.syncService, this.store) {
    WidgetsBinding.instance.addObserver(this);
  }

  /// ---------------------------------------------------------------------
  /// FACTORY: Inicjalizacja zależności i tworzenie kontrolera
  /// ---------------------------------------------------------------------
  static Future<AppSessionController> create() async {
    log('Initializing AppSessionController dependencies...');

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // 1. Otwieranie Boxów Hive
    // Box z postępem (już zainicjalizowany w LocalSaves.init(), ale pobieramy referencję)
    final progressBox = Hive.box<LevelProgress>(LocalSaves.levelProgressBoxName);
    
    // Boxy wymagane przez SyncService (otwieramy je tutaj, jeśli nie są w LocalSaves)
    final resultsBox = await Hive.openBox('game_results_sync');
    final queueBox = await Hive.openBox('sync_queue');

    // 2. Wstrzykiwanie zależności
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

  /// Główna logika reagowania na zmiany stanu Firebase Auth
  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      // --- SCENARIUSZ: WYLOGOWANIE (Po stronie Firebase) ---
      log('Auth state: User logged out');
      _state = SessionState.unauthenticated;

      // Zatrzymanie serwisu (fallback, jeśli signOut() nie był wywołany ręcznie)
      syncService.stop();

      // UWAGA ZGODNA ZE SPECYFIKACJĄ:
      // Nie czyścimy tutaj danych (clearSensitiveData).
      // Dane "pending" muszą zostać w Hive do następnego logowania.
      
      notifyListeners();
    } else {
      // --- SCENARIUSZ: ZALOGOWANIE ---
      log('Auth state: User logged in (${user.uid})');
      _state = SessionState.bootstrapping;
      notifyListeners();

      // Odblokowanie zapisu (jeśli był zablokowany przy wylogowaniu)
      store.disableWrites(false);

      // Uruchomienie serwisu synchronizacji
      await syncService.start();

      // Rozpoczęcie pobierania danych (Bootstrap)
      await syncService.bootstrapAfterLogin();

      // [WYMAGANIE] Powiadomienie UI, że dane są gotowe do wyświetlenia
      log('Bootstrap finished. Broadcasting data refresh event.');
      _refreshController.add(DataRefreshEvent.bootstrapCompleted);

      // Zmiana stanu na uwierzytelniony - aplikacja staje się interaktywna
      _state = SessionState.authenticated;
      notifyListeners();
    }
  }

  /// Obsługa cyklu życia aplikacji (powrót z tła)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _state == SessionState.authenticated) {
      log('App Resumed: Triggering sync check...');
      syncService.triggerSync();
    }
  }

  /// ---------------------------------------------------------------------
  /// PROCEDURA WYLOGOWANIA (ZGODNA ZE SPECYFIKACJĄ)
  /// ---------------------------------------------------------------------
  Future<void> signOut() async {
    log('Initiating Logout Sequence...');

    // 1. Natychmiastowa blokada zapisu nowych danych przez UI
    store.disableWrites(true);
    _state = SessionState.loggingOut;
    notifyListeners();

    try {
      // 2. Sprawdzenie, czy są dane oczekujące na wysyłkę
      final bool hasPendingData = store.hasPendingData();

      if (hasPendingData) {
        // 3. Sprawdzenie łączności z internetem
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
            // 4. Próba synchronizacji z timeoutem (max 3 sekundy)
            // Wymaga zaktualizowanego SyncService z obsługą parametru `timeout`
            await syncService.syncNow(
              reason: 'logout',
              timeout: const Duration(seconds: 3),
            );
            log('Logout: Sync completed successfully.');
          } catch (e) {
            log('Logout: Sync failed or timed out. Proceeding anyway. Error: $e');
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
      // 5. Zatrzymanie serwisu synchronizacji (zawsze)
      syncService.stop();

      // 6. Właściwe wylogowanie z Firebase
      // To wywoła listener _handleAuthStateChange, który zmieni stan na unauthenticated
      await _auth.signOut();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _refreshController.close(); // Zamknięcie strumienia odświeżania
    syncService.stop();
    super.dispose();
  }
}