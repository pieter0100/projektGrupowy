import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projekt_grupowy/screens/auth/sign_up_screen.dart';

// --- DODAJ TEN IMPORT (dostosuj ścieżkę jeśli jest inna) ---
import 'package:projekt_grupowy/services/auth_service.dart';

import 'package:projekt_grupowy/screens/auth/change_password_screen.dart';
import 'package:projekt_grupowy/screens/auth/forgot_password_screen.dart';
import 'package:projekt_grupowy/screens/auth/login_screen.dart';
import 'package:projekt_grupowy/screens/personal_data.dart';

import 'widgets/scaffold_with_nav.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/level_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/practice_end_screen.dart';
import 'screens/typed_screen.dart';
import 'screens/typed_screen_end.dart';

// -----------------------------------------------------------------------------
// KLASA POMOCNICZA: Zamienia Stream z Firebase na Listenable dla GoRoutera
// -----------------------------------------------------------------------------
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Instancja Twojego serwisu autoryzacji
final AuthService _authService = AuthService();

// -----------------------------------------------------------------------------
// KONFIGURACJA ROUTERA
// -----------------------------------------------------------------------------
final GoRouter appRouter = GoRouter(
  initialLocation: '/level',
  
  // 1. Odświeżaj router za każdym razem, gdy użytkownik się zaloguje/wyloguje
  refreshListenable: GoRouterRefreshStream(_authService.onAuthStateChanged),

  // 2. Globalna logika przekierowań (Guard)
  redirect: (BuildContext context, GoRouterState state) {
    // Sprawdź, czy użytkownik jest obecnie zalogowany w Firebase
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // Zdefiniuj, które ścieżki należą do procesu logowania/rejestracji
    final bool isGoingToAuthPage = state.matchedLocation == '/login' ||
        state.matchedLocation == '/login/forgot' ||
        state.matchedLocation == '/login/change' ||
        state.matchedLocation == '/signup'; // Dodane na zapas, jeśli zrobisz ten ekran

    // SCENARIUSZ 1: Użytkownik NIE JEST zalogowany
    if (!isLoggedIn) {
      // Jeśli próbuje wejść na chroniony ekran, wyrzuć go do logowania
      if (!isGoingToAuthPage) {
        return '/login';
      }
      return null; // Pozwól mu wejść na stronę logowania
    }

    // SCENARIUSZ 2: Użytkownik JEST zalogowany
    if (isLoggedIn) {
      // Jeśli jest zalogowany i próbuje wejść na logowanie, przenieś go do aplikacji
      if (isGoingToAuthPage) {
        return '/level';
      }
    }

    // null oznacza "wszystko jest ok, nie rób żadnego przekierowania"
    return null;
  },

  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNav(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/level',
              builder: (context, state) => const LevelScreen(levelsAmount: 8),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/leaderboard',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/level/learn',
      builder: (context, state) {
        final level = state.uri.queryParameters['level'] ?? "1";
        return LearnScreen(level: level);
      },
    ),

    GoRoute(
      path: '/level/learn/practice',
      builder: (context, state) {
        final level = state.uri.queryParameters['level'] ?? "1";
        return PracticeScreen(level: level);
      },
    ),

    GoRoute(
      path: '/level/learn/practice/end',
      builder: (context, state) {
        final level = state.uri.queryParameters['level'] ?? "1";
        return PracticeEndScreen(level: level);
      },
    ),

    GoRoute(
      path: '/level/learn/exam',
      builder: (context, state) {
        final level = state.uri.queryParameters['level'] ?? "1";
        return TypedScreen(level: int.parse(level), isPracticeMode: false);
      },
    ),

    GoRoute(
      path: '/level/learn/exam/end',
      builder: (context, state) {
        final levelStr = state.uri.queryParameters['level'] ?? "1";
        final scoreStr = state.uri.queryParameters['score'] ?? "0";

        return ExamTypedEndScreen(
          level: int.tryParse(levelStr) ?? 1,
          score: int.tryParse(scoreStr) ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/personal-data',
      builder: (context, state) => const PersonalData(),
    ),

    // --- EKRANY AUTORYZACJI ---
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      routes: [
        GoRoute(
          path: 'forgot',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: 'change',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ]
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    )
  ],
);