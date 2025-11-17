import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_router.dart';
import 'game_logic/user.dart';
import 'game_logic/user_profile.dart';
import 'game_logic/user_stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // needed for async in main

  await Hive.initFlutter(); // Initialize Hive

  Hive.registerAdapter(UserAdapter());          // Register User adapter
  Hive.registerAdapter(UserProfileAdapter());   // Register UserProfile adapter
  Hive.registerAdapter(UserStatsAdapter());     // Register UserStats adapter

  final usersBox = await Hive.openBox<User>('usersBox'); // Open a box for User objects

  final user1 = User(
    userId: 'user123',
    profile: UserProfile(displayName: 'PlayerOne', age: 10),
    stats: UserStats(totalGamesPlayed: 5, totalPoints: 1500, currentStreak: 2, lastPlayedAt: DateTime(  2024, 6, 1)),
  );

  final user2 = User(
    userId: 'user456',
    profile: UserProfile(displayName: 'GamerGirl', age: 12),
    stats: UserStats(totalGamesPlayed: 8, totalPoints: 2400, currentStreak: 4, lastPlayedAt: DateTime(2024, 6, 2)),
  );

  print('Original user1: ${user1.toString()}');
  print('Original user2: ${user2.toString()}');

  await usersBox.put(user1.userId, user1); // Store the user object
  await usersBox.put(user2.userId, user2); // Store the user object

  // Update user1's totalPoints
  final updatedUser1 = user1.copyWith(
    stats: user1.stats.copyWith(totalPoints: 3000),
  );
  
  print('Updated user1: ${updatedUser1.toString()}');

  await usersBox.put(updatedUser1.userId, updatedUser1);

  final retrievedUser1 = usersBox.get('user123');
  final retrievedUser2 = usersBox.get('user456');

  print('Retrieved user1: ${retrievedUser1.toString()}');
  print('Retrieved user2: ${retrievedUser2.toString()}');

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


