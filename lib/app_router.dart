import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:projekt_grupowy/screens/home_screen.dart';
import 'package:projekt_grupowy/screens/level_screen.dart';
import 'package:projekt_grupowy/screens/profile_screen.dart';
import 'main.dart';

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
        GoRoute(path: 'level',
        builder: (BuildContext context, GoRouterState state) {
            return LevelScreen();
          },
        )
      ],
    ),
  ],
);