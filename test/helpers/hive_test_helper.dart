import 'package:hive/hive.dart';
import 'package:projekt_grupowy/models/user/user.dart';
import 'package:projekt_grupowy/models/user/user_profile.dart';
import 'package:projekt_grupowy/models/user/user_stats.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';
import 'package:projekt_grupowy/models/leaderboard/leaderboard.dart';
import 'package:projekt_grupowy/models/leaderboard/leaderboard_entry.dart';

/// Helper class for initializing Hive in tests without Flutter dependencies
class HiveTestHelper {
  static bool _initialized = false;

  /// Initialize Hive for testing (without Flutter)
  static Future<void> init() async {
    if (_initialized) return;

    // Use in-memory storage for tests
    Hive.init('./test/.hive_test');

    // Register all adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserStatsAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(LevelProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(LevelInfoAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(UnlockRequirementsAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(RewardsAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(LeaderboardAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(LeaderboardEntryAdapter());
    }

    // Open all boxes
    await Hive.openBox<User>('users');
    await Hive.openBox<LevelProgress>('levelProgress');
    await Hive.openBox<LevelInfo>('levels');
    await Hive.openBox<Leaderboard>('leaderboard');

    _initialized = true;
  }

  /// Clean up Hive after tests
  static Future<void> cleanup() async {
    if (!_initialized) return;
    
    await Hive.close();
    _initialized = false;
  }
}
