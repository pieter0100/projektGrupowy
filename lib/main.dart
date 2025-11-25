// main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Zaimportuj swoje pliki
import 'widgets/scaffold_with_nav.dart';
import 'screens/home_screen.dart';
import 'screens/level_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/practice_screen.dart';

void main() {
  runApp(MyApp());
}

// Stwórz konfigurację routera
final GoRouter _router = GoRouter(
  initialLocation: '/home', // Domyślna ścieżka
  routes: [
    // 🤖 To jest nasza główna trasa z zakładkami
    StatefulShellRoute.indexedStack(
      
      // Budowniczy 'powłoki' (naszego widgetu z BottomNavBar)
      builder: (context, state, navigationShell) {
        return ScaffoldWithNav(navigationShell: navigationShell);
      },

      // Definicja "gałęzi" (branches), czyli naszych zakładek
      branches: [
        
        // --- GAŁĄŹ 1: LEVEL ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/level',
              builder: (context, state) => const LevelScreen(levelsAmount: 8,),
            ),
          ],
        ),

        // --- GAŁĄŹ 2: SZUKAJ ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // --- GAŁĄŹ 3: PROFIL ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),

        // --- GAŁĄŹ 4: SETTINGS ---
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
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GoRouter Bottom Nav',
    );
  }
}