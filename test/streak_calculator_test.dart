import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:projekt_grupowy/models/user/user_stats.dart';
import 'package:projekt_grupowy/utils/streak_calculator.dart';

void main() {
  final logger = Logger();
  group('StreakCalculator', () {
    
    test('First game should have streak of 1', () {
      // Arrange
      final farPast = DateTime(2000, 1, 1); // First play (no prior play)
      final stats = UserStats(
        totalGamesPlayed: 0,
        totalPoints: 0,
        currentStreak: 0,
        lastPlayedAt: farPast,
      );

      // Act
      final updatedStats = StreakCalculator.updateStreak(stats, DateTime.now());

      // Log
      logger.d('TEST: First game');
      logger.d('  Initial streak: ${stats.currentStreak}');
      logger.d('  Updated streak: ${updatedStats.currentStreak}');
      logger.d('  Games played: ${updatedStats.totalGamesPlayed}');

      // Assert
      expect(updatedStats.currentStreak, equals(1));
      expect(updatedStats.totalGamesPlayed, equals(1));
    });

    test('Playing again on same day should keep streak', () {
      // Arrange
      final now = DateTime.now();
      final stats = UserStats(
        totalGamesPlayed: 1,
        totalPoints: 100,
        currentStreak: 1,
        lastPlayedAt: now.subtract(Duration(hours: 1)), // 1 hour ago, same day
      );

      logger.d('TEST: Same day consecutive plays');
      logger.d('  Previous streak: ${stats.currentStreak}');

      // Act
      final updatedStats = StreakCalculator.updateStreak(stats, now);

      logger.d('  Updated streak: ${updatedStats.currentStreak}');

      // Assert
      expect(updatedStats.currentStreak, equals(1)); // Should not change
      expect(updatedStats.totalGamesPlayed, equals(2));
    });

    test('Playing on consecutive day should increment streak', () {
      // Arrange
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));
      
      final stats = UserStats(
        totalGamesPlayed: 1,
        totalPoints: 100,
        currentStreak: 1,
        lastPlayedAt: yesterday,
      );

      // Act
      final updatedStats = StreakCalculator.updateStreak(stats, today);

      // Log
      logger.d('TEST: Consecutive day play');
      logger.d('  Last played: ${stats.lastPlayedAt.toString().split(' ')[0]}');
      logger.d('  Playing today: ${today.toString().split(' ')[0]}');
      logger.d('  Previous streak: ${stats.currentStreak}');
      logger.d('  Updated streak: ${updatedStats.currentStreak}');

      // Assert
      expect(updatedStats.currentStreak, equals(2)); // Incremented
      expect(updatedStats.totalGamesPlayed, equals(2));
    });

    test('Missing a day should reset streak to 1', () {
      // Arrange
      final today = DateTime.now();
      final twoDaysAgo = today.subtract(Duration(days: 2));
      
      final stats = UserStats(
        totalGamesPlayed: 5,
        totalPoints: 500,
        currentStreak: 5,
        lastPlayedAt: twoDaysAgo, // Missed yesterday
      );

      // Act
      final updatedStats = StreakCalculator.updateStreak(stats, today);

      // Log
      logger.d('TEST: Missing a day (streak break)');
      logger.d('  Last played: ${stats.lastPlayedAt.toString().split(' ')[0]}');
      logger.d('  Today: ${today.toString().split(' ')[0]}');
      logger.d('  Days missed: 2');
      logger.d('  Previous streak: ${stats.currentStreak}');
      logger.d('  Updated streak: ${updatedStats.currentStreak}');

      // Assert
      expect(updatedStats.currentStreak, equals(1)); // Reset
      expect(updatedStats.totalGamesPlayed, equals(6));
    });

    test('Multiple consecutive days should build streak correctly', () {
      // Arrange & Act
      var stats = UserStats(
        totalGamesPlayed: 0,
        totalPoints: 0,
        currentStreak: 0,
        lastPlayedAt: DateTime(2000, 1, 1), // No prior play
      );

      logger.d('TEST: Multiple consecutive days');

      // Day 1
      var now = DateTime(2026, 5, 1, 12, 0, 0);
      stats = StreakCalculator.updateStreak(stats, now);
      logger.d('  Day 1 (05-01): Streak = ${stats.currentStreak}');
      expect(stats.currentStreak, equals(1));

      // Day 2
      now = DateTime(2026, 5, 2, 12, 0, 0);
      stats = StreakCalculator.updateStreak(stats, now);
      logger.d('  Day 2 (05-02): Streak = ${stats.currentStreak}');
      expect(stats.currentStreak, equals(2));

      // Day 3
      now = DateTime(2026, 5, 3, 12, 0, 0);
      stats = StreakCalculator.updateStreak(stats, now);
      logger.d('  Day 3 (05-03): Streak = ${stats.currentStreak}');
      expect(stats.currentStreak, equals(3));

      // Day 4
      now = DateTime(2026, 5, 4, 12, 0, 0);
      stats = StreakCalculator.updateStreak(stats, now);
      logger.d('  Day 4 (05-04): Streak = ${stats.currentStreak}');
      expect(stats.currentStreak, equals(4));

      // Assert final state
      logger.d('  Final: ${stats.totalGamesPlayed} games, Streak = ${stats.currentStreak}');
      expect(stats.totalGamesPlayed, equals(4));
      expect(stats.currentStreak, equals(4));
    });

    test('Streak should survive same-day multiple plays', () {
      // Arrange
      final now = DateTime.now();
      var stats = UserStats(
        totalGamesPlayed: 0,
        totalPoints: 0,
        currentStreak: 0,
        lastPlayedAt: DateTime(2000, 1, 1), // No prior play
      );

      logger.d('TEST: Same-day multiple plays');

      // Act: Play 3 times on same day
      stats = StreakCalculator.updateStreak(stats, now);
      logger.d('  Play 1: Streak = ${stats.currentStreak}, Games = ${stats.totalGamesPlayed}');

      stats = StreakCalculator.updateStreak(stats, now.add(Duration(minutes: 30)));
      logger.d('  Play 2: Streak = ${stats.currentStreak}, Games = ${stats.totalGamesPlayed}');

      stats = StreakCalculator.updateStreak(stats, now.add(Duration(hours: 2)));
      logger.d('  Play 3: Streak = ${stats.currentStreak}, Games = ${stats.totalGamesPlayed}');

      // Assert
      expect(stats.currentStreak, equals(1)); // Streak should be 1 (same day)
      expect(stats.totalGamesPlayed, equals(3)); // But 3 games played
    });

    test('addGameScore should increase total points', () {
      // Arrange
      final stats = UserStats(
        totalGamesPlayed: 5,
        totalPoints: 500,
        currentStreak: 3,
        lastPlayedAt: DateTime.now(),
      );

      logger.d('TEST: Score addition');
      logger.d('  Previous points: ${stats.totalPoints}');
      logger.d('  Adding score: 150');

      // Act
      final updatedStats = StreakCalculator.addGameScore(stats, 150);

      logger.d('  Updated points: ${updatedStats.totalPoints}');

      // Assert
      expect(updatedStats.totalPoints, equals(650));
      expect(updatedStats.totalGamesPlayed, equals(5)); // Unchanged
      expect(updatedStats.currentStreak, equals(3)); // Unchanged
    });

    test('Large streak should be preserved across plays', () {
      // Arrange
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));
      
      var stats = UserStats(
        totalGamesPlayed: 100,
        totalPoints: 10000,
        currentStreak: 50,
        lastPlayedAt: yesterday,
      );

      logger.d('TEST: Large streak preservation');
      logger.d('  Previous streak: ${stats.currentStreak}');

      // Act: Play again today (consecutive day)
      stats = StreakCalculator.updateStreak(stats, today);

      logger.d('  Updated streak: ${stats.currentStreak}');

      // Assert
      expect(stats.currentStreak, equals(51)); // Incremented from 50
    });

    test('Streak should break after more than 1 day gap', () {
      // Arrange
      final today = DateTime.now();
      final threeDaysAgo = today.subtract(Duration(days: 3));
      
      final stats = UserStats(
        totalGamesPlayed: 10,
        totalPoints: 1000,
        currentStreak: 10,
        lastPlayedAt: threeDaysAgo,
      );

      logger.d('TEST: Streak break after gap');
      logger.d('  Previous streak: ${stats.currentStreak}');
      logger.d('  Days gap: 3');

      // Act
      final updatedStats = StreakCalculator.updateStreak(stats, today);

      logger.d('  Updated streak: ${updatedStats.currentStreak}');

      // Assert
      expect(updatedStats.currentStreak, equals(1)); // Reset
    });
  });
}
