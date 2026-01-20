import 'package:go_router/go_router.dart';

// Import your Controller
import '../controllers/app_session_controller.dart'; 

// Existing Screen Imports
import '../widgets/scaffold_with_nav.dart'; 
import '../screens/leaderboard_screen.dart'; 
import '../screens/level_screen.dart'; 
import '../screens/profile_screen.dart'; 
import '../screens/learn_screen.dart'; 
import '../screens/settings_screen.dart'; 
import '../screens/practice_screen.dart'; 
import '../screens/practice_end_screen.dart'; 
import '../screens/typed_screen.dart'; 
import '../screens/MC_screen.dart'; 
import '../screens/test.dart';

// --- ASSUMED IMPORTS (Create these screens or update imports) ---
// import '../screens/login_screen.dart';    // You need to create/import this
// import '../screens/register_screen.dart'; // You need to create/import this
// import '../screens/loading_screen.dart';  // You need to create/import this

/// Returns the router instance configured with Auth Guards
GoRouter createAppRouter(AppSessionController controller) {
  return GoRouter(
    initialLocation: '/level',
    debugLogDiagnostics: true,
    
    // 1. Trigger redirect logic whenever the controller notifies changes
    refreshListenable: controller,

    // 2. Core Redirect Logic
    redirect: (context, state) {
      final sessionState = controller.state;
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';
      final isLoading = state.uri.path == '/loading';

      // CASE A: User is NOT logged in
      if (sessionState == SessionState.unauthenticated) {
        // If not already on login or register, go to login
        if (!isLoggingIn && !isRegistering) {
          return '/test';
        }
        return null; // Stay on login or register
      }

      // CASE B: User is in the process of syncing (Bootstrapping)
      if (sessionState == SessionState.bootstrapping) {
        if (!isLoading) {
          return '/loading';
        }
        return null;
      }

      // CASE C: User IS logged in and synced (Authenticated)
      if (sessionState == SessionState.authenticated) {
        // If trying to access login, register, or loading, send to Home
        if (isLoggingIn || isRegistering || isLoading) {
          return '/level';
        }
        // Otherwise, let them go where they want
        return null;
      }
      
      // CASE D: Logging Out (New state from previous step)
      if (sessionState == SessionState.loggingOut) {
         return '/loading'; // Show loading while syncing/logging out
      }

      return null;
    },

    routes: [
      // --- AUTH ROUTES ---
      GoRoute(
        path: '/login',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const SettingsScreen(),
      ),

      // --- MAIN APP (SHELL ROUTE) ---
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

      // --- SUB-ROUTES ---
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
      GoRoute(
          path: '/test',
          builder: (context, state) => const TestDashboardScreen()),
    ],
  );
}