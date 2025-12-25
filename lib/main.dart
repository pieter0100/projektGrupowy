import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';


import 'widgets/scaffold_with_nav.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/level_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/practice_end_screen.dart';
import 'game_logic/local_saves.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and all adapters
  await LocalSaves.init();

  // Run tests
  await LocalSaves.testAllClasses();

  // Initialize firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}

// router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/level',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNav(navigationShell: navigationShell);
      },

      // branches definitiion
      branches: [
        // --- BRANCH 1: LEVEL ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/level',
              builder: (context, state) => const LevelScreen(levelsAmount: 8),
            ),
          ],
        ),

        // --- BRANCH 2: SZUKAJ ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/leaderboard',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // --- BRANCH 3: PROFIL ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),

        // --- BRANCH 4: SETTINGS ---
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
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GoRouter Bottom Nav',
    );
  }
}
