import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

final GoRouter appRouter = GoRouter(
  initialLocation: '/level',
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
        return TypedScreen(
          level: int.parse(level),
          isPracticeMode: false,
        );
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
  ],
);