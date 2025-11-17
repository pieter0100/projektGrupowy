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
        
        // --- GAŁĄŹ 1: DOM ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/level', // Ścieżka URL
              builder: (context, state) => const LevelScreen(),
              // Możesz tu zagnieżdżać dalsze trasy, np. /home/details/1
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

        // --- GAŁĄŹ 4: LEARN ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/learn',
              builder: (context, state) => const LearnScreen(),
            ),
          ],
        ),

        // --- GAŁĄŹ 5: SETTINGS ---
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
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Użyj .router() zamiast zwykłego MaterialApp
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GoRouter Bottom Nav',
    );
  }
}