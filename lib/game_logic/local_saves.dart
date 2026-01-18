import 'package:hive_flutter/hive_flutter.dart';
import '../models/user/user.dart';
import '../models/user/user_profile.dart';
import '../models/user/user_stats.dart';
import '../models/level/level_progress.dart';
import '../models/level/level.dart';
import '../models/level/unlock_requirements.dart';
import '../models/leaderboard/leaderboard.dart';
import '../models/leaderboard/leaderboard_entry.dart';
import 'package:logger/logger.dart';

class LocalSaves {
  // Box names
  static const String usersBoxName = 'users';
  static const String levelProgressBoxName = 'levelProgress';
  static const String levelsBoxName = 'levels';
  static const String leaderboardBoxName = 'leaderboard';

  // Logger instance
  static final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: false,
    ),
  );

  // Initialize Hive and register all adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register all adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(UserStatsAdapter());
    Hive.registerAdapter(LevelProgressAdapter());
    Hive.registerAdapter(LevelInfoAdapter());
    Hive.registerAdapter(UnlockRequirementsAdapter());
    Hive.registerAdapter(RewardsAdapter());
    Hive.registerAdapter(LeaderboardAdapter());
    Hive.registerAdapter(LeaderboardEntryAdapter());

    // Open all boxes
    await Hive.openBox<User>(usersBoxName);
    await Hive.openBox<LevelProgress>(levelProgressBoxName);
    await Hive.openBox<LevelInfo>(levelsBoxName);
    await Hive.openBox<Leaderboard>(leaderboardBoxName);
  }

  // === USER OPERATIONS ===

  static Future<void> saveUser(User user) async {
    final box = Hive.box<User>(usersBoxName);
    await box.put(user.userId, user);
    logger.i('Saved user: ${user.userId}');
  }

  static User? getUser(String userId) {
    final box = Hive.box<User>(usersBoxName);
    return box.get(userId);
  }

  static Future<void> updateUserStats(String userId, UserStats newStats) async {
    final user = getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(stats: newStats);
      await saveUser(updatedUser);
      logger.i('Updated stats for user: $userId');
    }
  }

  static Future<void> updateUserProfile(String userId, UserProfile newProfile) async {
    final user = getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(profile: newProfile);
      await saveUser(updatedUser);
      logger.i('Updated profile for user: $userId');
    }
  }

  static List<User> getAllUsers() {
    final box = Hive.box<User>(usersBoxName);
    return box.values.toList();
  }

  // === LEVEL PROGRESS OPERATIONS ===

  static Future<void> saveLevelProgress(String userId, LevelProgress progress) async {
    final box = Hive.box<LevelProgress>(levelProgressBoxName);
    final key = '${userId}_${progress.levelId}';
    await box.put(key, progress);
    logger.i('Saved level progress: $key');
  }

  static LevelProgress? getLevelProgress(String userId, String levelId) {
    final box = Hive.box<LevelProgress>(levelProgressBoxName);
    final key = '${userId}_$levelId';
    return box.get(key);
  }

  static List<LevelProgress> getAllLevelProgressForUser(String userId) {
    final box = Hive.box<LevelProgress>(levelProgressBoxName);
    return box.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .map((key) => box.get(key))
        .whereType<LevelProgress>()
        .toList();
  }

  // === LEVEL INFO OPERATIONS ===

  static Future<void> saveLevel(LevelInfo level) async {
    final box = Hive.box<LevelInfo>(levelsBoxName);
    await box.put(level.levelId, level);
    logger.i('Saved level: ${level.levelId}');
  }

  static LevelInfo? getLevel(String levelId) {
    final box = Hive.box<LevelInfo>(levelsBoxName);
    return box.get(levelId);
  }

  static List<LevelInfo> getAllLevels() {
    final box = Hive.box<LevelInfo>(levelsBoxName);
    return box.values.toList();
  }

  static bool isLevelUnlocked(String userId, String levelId) {
    if (levelId == '1') return true;

    final levelInfo = getLevel(levelId);
    final user = getUser(userId);

    if (levelInfo == null || user == null) {
      logger.w('Level info or user not found for check: $levelId, $userId');
      return false;
    }

    final requirements = levelInfo.unlockRequirements;

    // Check points requirement
    if (requirements.minPoints != null &&
        requirements.minPoints! > user.stats.totalPoints) {
      return false;
    }

    // Check previous level requirement
    if (requirements.previousLevelId != null) {
      final previousProgress =
          getLevelProgress(userId, requirements.previousLevelId!);

      if (previousProgress == null || !previousProgress.completed) {
        return false;
      }
    }

    return true;
  }

  // === LEADERBOARD OPERATIONS ===

  static Future<void> saveLeaderboard(Leaderboard leaderboard) async {
    final box = Hive.box<Leaderboard>(leaderboardBoxName);
    await box.put('global', leaderboard);
    logger.i('Saved global leaderboard');
  }

  static Leaderboard? getGlobalLeaderboard() {
    final box = Hive.box<Leaderboard>(leaderboardBoxName);
    return box.get('global');
  }

  static Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    final leaderboard = getGlobalLeaderboard();

    if (leaderboard != null) {
      final updatedEntries = [...leaderboard.entries, entry];
      final updatedLeaderboard = leaderboard.copyWith(
        entries: updatedEntries,
        lastUpdated: DateTime.now(),
      );
      await saveLeaderboard(updatedLeaderboard);
      logger.i('Added leaderboard entry for: ${entry.playerName}');
    } else {
      final newLeaderboard = Leaderboard(
        entries: [entry],
        lastUpdated: DateTime.now(),
      );
      await saveLeaderboard(newLeaderboard);
      logger.i('Created new leaderboard with entry for: ${entry.playerName}');
    }
  }

  // === CLEAR ALL DATA (for debugging or tests) ===

  static Future<void> clearAllData() async {
    await Hive.box<User>(usersBoxName).clear();
    await Hive.box<LevelProgress>(levelProgressBoxName).clear();
    await Hive.box<LevelInfo>(levelsBoxName).clear();
    await Hive.box<Leaderboard>(leaderboardBoxName).clear();
    logger.i('All data cleared');
  }
}
