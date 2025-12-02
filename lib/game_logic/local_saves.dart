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
      
    )
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
      // Create new leaderboard if it doesn't exist
      final newLeaderboard = Leaderboard(
        entries: [entry],
        lastUpdated: DateTime.now(),
      );
      await saveLeaderboard(newLeaderboard);
      logger.i('Created new leaderboard with entry for: ${entry.playerName}');
    }
  }

  // === TESTING FUNCTION ===

  static Future<void> testAllClasses() async {
    logger.i('\n=== TESTING ALL CLASSES ===\n');

    // 1. Test User, UserProfile, UserStats
    logger.i('Testing User classes...');
    final user = User(
      userId: 'user123',
      profile: UserProfile(displayName: 'TestPlayer', age: 25),
      stats: UserStats(
        totalGamesPlayed: 10,
        totalPoints: 500,
        currentStreak: 3,
        lastPlayedAt: DateTime.now(),
      ),
    );
    await saveUser(user);
    
    final retrievedUser = getUser('user123');
    logger.i('Retrieved user: ${retrievedUser?.toString()}');

    // Test immutability - try to update stats
    logger.i('Testing immutability - updating stats...');
    final updatedStats = user.stats.copyWith(totalPoints: 1000);
    await updateUserStats('user123', updatedStats);
    final userAfterUpdate = getUser('user123');
    logger.i('User after stats update: ${userAfterUpdate?.stats.toString()}');
    // 2. Test LevelProgress
    logger.i('\nTesting LevelProgress...');
    final progress = LevelProgress(
      levelId: 'multiply-by-2',
      bestScore: 100,
      bestTimeSeconds: 45,
      attempts: 5,
      completed: true,
      firstCompletedAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
    );
    await saveLevelProgress('user123', progress);
    
    final retrievedProgress = getLevelProgress('user123', 'multiply-by-2');
    logger.i('Retrieved progress: ${retrievedProgress?.toString()}');

    // 3. Test LevelInfo with nested classes
    logger.i('\nTesting LevelInfo with UnlockRequirements and Rewards...');
    final level = LevelInfo(
      levelId: 'multiply-by-2',
      levelNumber: 1,
      name: 'Multiply by 2',
      description: 'Learn multiplication by 2',
      unlockRequirements: UnlockRequirements(
        minPoints: 0,
        previousLevelId: null,
      ),
      rewards: Rewards(points: 100),
      isRevision: false,
    );
    await saveLevel(level);
    
    final retrievedLevel = getLevel('multiply-by-2');
    logger.i('Retrieved level: ${retrievedLevel?.toString()}');

    // 4. Test Leaderboard and LeaderboardEntry
    logger.i('\nTesting Leaderboard...');
    final entry1 = LeaderboardEntry(
      playerId: 'user123',
      playerName: 'TestPlayer',
      streak: 5,
      dateAchieved: DateTime.now(),
    );
    await addLeaderboardEntry(entry1);
    
    final entry2 = LeaderboardEntry(
      playerId: 'user456',
      playerName: 'AnotherPlayer',
      streak: 8,
      dateAchieved: DateTime.now(),
    );
    await addLeaderboardEntry(entry2);
    
    final leaderboard = getGlobalLeaderboard();
    logger.i('Global leaderboard: ${leaderboard?.toString()}');
    logger.i('Number of entries: ${leaderboard?.entries.length}');

    // 5. Test immutability on nested objects
    logger.i('Testing immutability - trying to modify LevelInfo rewards...');
    if (retrievedLevel != null) {
      final updatedRewards = Rewards(points: 200);
      final updatedLevel = retrievedLevel.copyWith(rewards: updatedRewards);
      await saveLevel(updatedLevel);
      
      final levelAfterUpdate = getLevel('multiply-by-2');
      logger.i('Level rewards after update: ${levelAfterUpdate?.rewards.points}');
    }

    logger.i('\n=== ALL TESTS COMPLETED ===\n');
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await Hive.box<User>(usersBoxName).clear();
    await Hive.box<LevelProgress>(levelProgressBoxName).clear();
    await Hive.box<LevelInfo>(levelsBoxName).clear();
    await Hive.box<Leaderboard>(leaderboardBoxName).clear();
    logger.i('All data cleared');
  }
}
