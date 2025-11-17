import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/screens/home_screen.dart';
import 'package:projekt_grupowy/screens/level_screen.dart';
import 'package:projekt_grupowy/screens/profile_screen.dart';
import 'package:projekt_grupowy/screens/settings_screen.dart';
import 'widgets/scaffold_with_nav.dart';

final GoRouter router = GoRouter(
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

        // --- GAŁĄŹ 2: LEADERBOARD ---
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
            )
          ]
        )
      ],
    ),
  ],
);