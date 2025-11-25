import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:projekt_grupowy/screens/home_screen.dart';
import 'package:projekt_grupowy/screens/level_screen.dart';
import 'package:projekt_grupowy/screens/profile_screen.dart';
import 'package:projekt_grupowy/screens/learn_screen.dart';
import 'package:projekt_grupowy/screens/settings_screen.dart';
import 'package:projekt_grupowy/screens/practice_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return ProfileScreen();
          },
        ),
        GoRoute(
          path: 'level',
          builder: (BuildContext context, GoRouterState state) {
            return LevelScreen(levelsAmount: 8);
          },
        ),
        GoRoute(
          path: 'learn',
          builder: (BuildContext context, GoRouterState state) {
            return LearnScreen();
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return SettingsScreen();
          },
        ),
        GoRoute(
          path: 'practice',
          builder: (BuildContext context, GoRouterState state) {
            return PracticeScreen();
          },
        ),
      ],
    ),
  ],
);