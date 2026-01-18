import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/user/user.dart';
import 'package:projekt_grupowy/models/user/user_profile.dart';
import 'package:projekt_grupowy/models/user/user_stats.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';
import 'package:projekt_grupowy/models/leaderboard/leaderboard.dart';
import 'package:projekt_grupowy/models/leaderboard/leaderboard_entry.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(UserStatsAdapter());
    Hive.registerAdapter(LevelProgressAdapter());
    Hive.registerAdapter(LevelInfoAdapter());
    Hive.registerAdapter(UnlockRequirementsAdapter());
    Hive.registerAdapter(RewardsAdapter());
    Hive.registerAdapter(LeaderboardAdapter());
    Hive.registerAdapter(LeaderboardEntryAdapter());

    await Hive.openBox<User>(LocalSaves.usersBoxName);
    await Hive.openBox<LevelProgress>(LocalSaves.levelProgressBoxName);
    await Hive.openBox<LevelInfo>(LocalSaves.levelsBoxName);
    await Hive.openBox<Leaderboard>(LocalSaves.leaderboardBoxName);
  });

  tearDown(() async {
    await Hive.box<User>(LocalSaves.usersBoxName).clear();
    await Hive.box<LevelProgress>(LocalSaves.levelProgressBoxName).clear();
    await Hive.box<LevelInfo>(LocalSaves.levelsBoxName).clear();
    await Hive.box<Leaderboard>(LocalSaves.leaderboardBoxName).clear();
  });

  group("USER TESTS", () {
    test("Save and retrieve user", () async {
      final user = User(
        userId: 'u1',
        profile: UserProfile(displayName: 'Test', age: 20),
        stats: UserStats(
          totalGamesPlayed: 5,
          totalPoints: 100,
          currentStreak: 1,
          lastPlayedAt: DateTime.now(),
        ),
      );

      await LocalSaves.saveUser(user);
      final retrieved = LocalSaves.getUser('u1');

      expect(retrieved?.userId, 'u1');
      expect(retrieved?.profile.displayName, 'Test');
    });

    test("Update user stats", () async {
      final user = User(
        userId: 'u1',
        profile: UserProfile(displayName: 'Test', age: 20),
        stats: UserStats(
          totalGamesPlayed: 5,
          totalPoints: 100,
          currentStreak: 1,
          lastPlayedAt: DateTime.now(),
        ),
      );

      await LocalSaves.saveUser(user);

      final newStats = user.stats.copyWith(totalPoints: 500);
      await LocalSaves.updateUserStats('u1', newStats);

      final updated = LocalSaves.getUser('u1');

      expect(updated?.stats.totalPoints, 500);
    });

    test("Get all users", () async {
      await LocalSaves.saveUser(
        User(
          userId: 'u1',
          profile: UserProfile(displayName: 'A', age: 20),
          stats: UserStats(
            totalGamesPlayed: 1,
            totalPoints: 10,
            currentStreak: 0,
            lastPlayedAt: DateTime.now(),
          ),
        ),
      );

      await LocalSaves.saveUser(
        User(
          userId: 'u2',
          profile: UserProfile(displayName: 'B', age: 30),
          stats: UserStats(
            totalGamesPlayed: 2,
            totalPoints: 20,
            currentStreak: 1,
            lastPlayedAt: DateTime.now(),
          ),
        ),
      );

      final users = LocalSaves.getAllUsers();
      expect(users.length, 2);
    });
  });

  group("LEVEL PROGRESS TESTS", () {
    test("Save and retrieve level progress", () async {
      final progress = LevelProgress(
        levelId: 'lvl1',
        bestScore: 100,
        bestTimeSeconds: 30,
        attempts: 3,
        completed: true,
        firstCompletedAt: DateTime.now(),
        lastPlayedAt: DateTime.now(),
      );

      await LocalSaves.saveLevelProgress('u1', progress);

      final retrieved = LocalSaves.getLevelProgress('u1', 'lvl1');

      expect(retrieved?.bestScore, 100);
      expect(retrieved?.completed, true);
    });

    test("Get all progress for user", () async {
      await LocalSaves.saveLevelProgress(
        'u1',
        LevelProgress(
          levelId: 'lvl1',
          bestScore: 50,
          bestTimeSeconds: 20,
          attempts: 1,
          completed: false,
          firstCompletedAt: DateTime.now(),
          lastPlayedAt: DateTime.now(),
        ),
      );

      await LocalSaves.saveLevelProgress(
        'u1',
        LevelProgress(
          levelId: 'lvl2',
          bestScore: 80,
          bestTimeSeconds: 25,
          attempts: 2,
          completed: true,
          firstCompletedAt: DateTime.now(),
          lastPlayedAt: DateTime.now(),
        ),
      );

      final list = LocalSaves.getAllLevelProgressForUser('u1');
      expect(list.length, 2);
    });
  });

  group("LEVEL INFO TESTS", () {
    test("Save and retrieve level", () async {
      final level = LevelInfo(
        levelId: 'lvl1',
        levelNumber: 1,
        name: 'Test Level',
        description: 'Desc',
        unlockRequirements: UnlockRequirements(minPoints: 0),
        rewards: Rewards(points: 10),
        isRevision: false,
      );

      await LocalSaves.saveLevel(level);

      final retrieved = LocalSaves.getLevel('lvl1');

      expect(retrieved?.name, 'Test Level');
    });

    test("Level unlocking logic", () async {
      final user = User(
        userId: 'u1',
        profile: UserProfile(displayName: 'Test', age: 20),
        stats: UserStats(
          totalGamesPlayed: 1,
          totalPoints: 500,
          currentStreak: 0,
          lastPlayedAt: DateTime.now(),
        ),
      );

      await LocalSaves.saveUser(user);

      await LocalSaves.saveLevel(
        LevelInfo(
          levelId: 'lvl1',
          levelNumber: 1,
          name: 'L1',
          description: '',
          unlockRequirements: UnlockRequirements(minPoints: 100),
          rewards: Rewards(points: 10),
          isRevision: false,
        ),
      );

      final unlocked = LocalSaves.isLevelUnlocked('u1', 'lvl1');
      expect(unlocked, true);
    });

    test("Level locked due to missing previous level", () async {
      await LocalSaves.saveUser(
        User(
          userId: 'u1',
          profile: UserProfile(displayName: 'A', age: 20),
          stats: UserStats(
            totalGamesPlayed: 1,
            totalPoints: 2000,
            currentStreak: 0,
            lastPlayedAt: DateTime.now(),
          ),
        ),
      );

      await LocalSaves.saveLevel(
        LevelInfo(
          levelId: 'lvl2',
          levelNumber: 2,
          name: 'L2',
          description: '',
          unlockRequirements: UnlockRequirements(
            minPoints: 0,
            previousLevelId: 'lvl1',
          ),
          rewards: Rewards(points: 10),
          isRevision: false,
        ),
      );

      final unlocked = LocalSaves.isLevelUnlocked('u1', 'lvl2');
      expect(unlocked, false);
    });
  });

  group("LEADERBOARD TESTS", () {
    test("Add leaderboard entry", () async {
      final entry = LeaderboardEntry(
        playerId: 'u1',
        playerName: 'Test',
        streak: 5,
        dateAchieved: DateTime.now(),
      );

      await LocalSaves.addLeaderboardEntry(entry);

      final leaderboard = LocalSaves.getGlobalLeaderboard();

      expect(leaderboard?.entries.length, 1);
    });

    test("Leaderboard appends entries", () async {
      await LocalSaves.addLeaderboardEntry(
        LeaderboardEntry(
          playerId: 'u1',
          playerName: 'A',
          streak: 3,
          dateAchieved: DateTime.now(),
        ),
      );

      await LocalSaves.addLeaderboardEntry(
        LeaderboardEntry(
          playerId: 'u2',
          playerName: 'B',
          streak: 7,
          dateAchieved: DateTime.now(),
        ),
      );

      final leaderboard = LocalSaves.getGlobalLeaderboard();

      expect(leaderboard?.entries.length, 2);
    });
  });
}
