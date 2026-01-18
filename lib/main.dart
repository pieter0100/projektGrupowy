import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projekt_grupowy/controllers/app_session_controller.dart';
import 'package:projekt_grupowy/screens/test.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:projekt_grupowy/screens/typed_screen.dart';
import 'package:projekt_grupowy/screens/MC_screen.dart';

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
  // await LocalSaves.testAllClasses();

  // Initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sessionController = await AppSessionController.create();

  runApp(
    MultiProvider(
      providers: [
        // Główny kontroler
        ChangeNotifierProvider.value(value: sessionController),

        Provider.value(value: sessionController.syncService),
        Provider.value(value: sessionController.store),
      ],
      child: const MyApp(),
    ),
  );
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
      path: '/level/learn/practice/typedAnswer',
      builder: (context, state) {
        final level = state.uri.queryParameters['level'] ?? "1";
        return TypedScreen(level: int.parse(level), isPracticeMode: true);
      },
    ),
    GoRoute(
      path: '/level/learn/practice/MC',
      builder: (context, state) {
        final level = state.uri.queryParameters['level'] ?? "1";
        return McScreen(level: int.parse(level));
      },
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

    GoRoute(path: '/test', builder: (context, state) => const TestDashboardScreen()),
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
