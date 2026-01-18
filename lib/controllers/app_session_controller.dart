import 'dart:async';
import 'dart:developer';
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
  unauthenticated, // Użytkownik niezalogowany (Ekran logowania)
  bootstrapping,   // Zalogowany, ale trwa pobieranie danych (Spinner)
  authenticated,   // Zalogowany i dane gotowe (Ekran główny)
}

class AppSessionController extends ChangeNotifier with WidgetsBindingObserver {
  final FirebaseAuth _auth;
  
  // Pola publiczne, aby można je było przekazać do Providera w main.dart
  final SyncService syncService;
  final OfflineStore store;

  SessionState _state = SessionState.unauthenticated;
  StreamSubscription<User?>? _authSubscription;

  /// Prywatny konstruktor - wymuszamy użycie metody fabrycznej create()
  AppSessionController._(this._auth, this.syncService, this.store) {
    // Rejestracja obserwatora cyklu życia (background/foreground)
    WidgetsBinding.instance.addObserver(this);
  }

  /// ---------------------------------------------------------------------
  /// STATIC FACTORY - Metoda inicjalizująca całą logikę aplikacji
  /// Wywołaj ją w main.dart przed runApp()
  /// ---------------------------------------------------------------------
  static Future<AppSessionController> create() async {
    log('Initializing AppSessionController dependencies...');

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // ---------------------------------------------------------
    // 1. INTEGRACJA Z HIVE (Poprawiona pod LocalSaves)
    // ---------------------------------------------------------
    
    // A. Postęp Gry (Progress)
    // LocalSaves.init() już otworzył ten box, więc używamy Hive.box()
    // Używamy stałej z Twojej klasy, żeby uniknąć literówek.
    final progressBox = Hive.box<LevelProgress>(LocalSaves.levelProgressBoxName);

    // B. Wyniki Gier (Results)
    // Twoja klasa LocalSaves NIE MA dedykowanego boxa na historię gier (ma leaderboard, users, levels).
    // SyncService potrzebuje miejsca na zapisywanie każdego wyniku z osobna przed wysłaniem.
    // Musimy otworzyć nowy box specjalnie dla synchronizacji:
    final resultsBox = await Hive.openBox('game_results_sync'); 

    // C. Kolejka Synchronizacji (Queue)
    // Tego też nie ma w LocalSaves, otwieramy go tutaj:
    final queueBox = await Hive.openBox('sync_queue');

    // ---------------------------------------------------------
    // 2. WSTRZYKIWANIE ZALEŻNOŚCI
    // ---------------------------------------------------------
    
    // Tworzymy Store (przekazujemy boxy)
    // UWAGA: OfflineStore musi obsługiwać typ <LevelProgress> w progressBox!
    final store = OfflineStore(resultsBox, progressBox);
    
    final syncService = SyncService(store, firestore, auth, queueBox);

    final controller = AppSessionController._(auth, syncService, store);
    controller._initialize();

    return controller;
  }

  /// Wewnętrzna inicjalizacja listenerów
  void _initialize() {
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  /// Getter stanu dla UI
  SessionState get state => _state;

  /// Główna logika reagowania na Zalogowanie / Wylogowanie
  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      // --- SCENARIUSZ: WYLOGOWANIE ---
      log('Auth state: User logged out');
      
      _state = SessionState.unauthenticated;
      notifyListeners();

      // 1. Zatrzymaj synchronizację
      syncService.stop();

      // 2. Wyczyść wrażliwe dane lokalne (dla bezpieczeństwa)
      // Upewnij się, że dodałeś metodę clearSensitiveData() do OfflineStore
      await store.clearSensitiveData();
      
    } else {
      // --- SCENARIUSZ: ZALOGOWANIE ---
      log('Auth state: User logged in (${user.uid})');

      _state = SessionState.bootstrapping;
      notifyListeners();

      // 1. Uruchom mechanizmy synchronizacji
      await syncService.start();

      // 2. Hydracja danych (pobranie z chmury)
      // To jest moment, w którym UI pokazuje spinner ładowania
      await syncService.bootstrapAfterLogin();

      // 3. Gotowe - wpuść użytkownika do aplikacji
      _state = SessionState.authenticated;
      notifyListeners();
    }
  }

  /// Obsługa cyklu życia aplikacji (Gdy apka wraca z tła)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _state == SessionState.authenticated) {
      log('App Resumed: Triggering sync check...');
      // Użytkownik wrócił do aplikacji -> sprawdźmy czy trzeba coś wysłać
      syncService.triggerSync();
    }
  }

  /// Metoda publiczna do wylogowania
  Future<void> signOut() async {
    await _auth.signOut();
    // Resztą zajmie się listener _handleAuthStateChange
  }

  /// Sprzątanie przy zamykaniu aplikacji (rzadko wywoływane w Flutterze, ale dobre dla porządku)
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    syncService.stop();
    super.dispose();
  }
}