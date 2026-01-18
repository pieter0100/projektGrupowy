import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projekt_grupowy/services/offline_store.dart';
import 'package:projekt_grupowy/services/sync_service.dart';

enum SessionState {
  unauthenticated, // Niezalogowany
  bootstrapping,   // Zalogowany, ale trwa pobieranie danych (spinner)
  authenticated,   // Zalogowany i dane gotowe (Home Screen)
}

class AppSessionController extends ChangeNotifier with WidgetsBindingObserver {
  final FirebaseAuth _auth;
  final SyncService _syncService;
  final OfflineStore _store;

  SessionState _state = SessionState.unauthenticated;
  StreamSubscription<User?>? _authSubscription;

  AppSessionController(this._auth, this._syncService, this._store) {
    // Rejestracja nasłuchiwania cyklu życia apki (tło/pierwszy plan)
    WidgetsBinding.instance.addObserver(this);
  }

  SessionState get state => _state;

  /// Startuje nasłuchiwanie zmian w Auth. Wywołaj to w main.dart lub przy starcie apki.
  void initialize() {
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      // 1. UŻYTKOWNIK SIĘ WYLOGOWAŁ
      _state = SessionState.unauthenticated;
      notifyListeners();

      // Zatrzymaj sync
      _syncService.stop();
      
      // WAŻNE: Wyczyść wrażliwe dane lokalne, by kolejny user ich nie zobaczył
      await _store.clearSensitiveData(); 
      
    } else {
      // 2. UŻYTKOWNIK SIĘ ZALOGOWAŁ
      _state = SessionState.bootstrapping;
      notifyListeners();

      // Uruchom serwis synchronizacji (kolejki, listenery sieci)
      await _syncService.start();

      // Wykonaj "Hydrację" (pobranie danych z chmury)
      // To może potrwać chwilę, dlatego mamy stan 'bootstrapping'
      await _syncService.bootstrapAfterLogin();

      _state = SessionState.authenticated;
      notifyListeners();
    }
  }

  /// Obsługa powrotu aplikacji z tła (Foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _state == SessionState.authenticated) {
      // Użytkownik wrócił do apki -> wymuś sprawdzenie czy są nowe dane
      print('App resumed - triggering sync');
      _syncService.triggerSync();
    }
  }

  /// Metoda do wywołania z przycisku "Wyloguj" w UI
  Future<void> signOut() async {
    await _auth.signOut();
    // Resztę załatwi _handleAuthStateChange
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _syncService.stop();
    super.dispose();
  }
}