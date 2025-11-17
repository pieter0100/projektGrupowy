import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_router.dart';
import 'game_logic/user.dart';
import 'game_logic/user_profile.dart';
import 'game_logic/user_stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // Initialize Hive

  Hive.registerAdapter(UserAdapter());          // Register User adapter
  Hive.registerAdapter(UserProfileAdapter());   // Register UserProfile adapter
  Hive.registerAdapter(UserStatsAdapter());     // Register UserStats adapter

  final usersBox = await Hive.openBox<User>('usersBox'); // Open a box for User objects

  final user = User(
    userId: 'user123',
    profile: UserProfile(displayName: 'PlayerOne', age: 10),
    stats: UserStats(totalGamesPlayed: 5, totalPoints: 1500, currentStreak: 2, lastPlayedAt: DateTime(  2024, 6, 1)),
  );

  print(user.toString());

  await usersBox.put(user.userId, user); // Store the user object

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}


