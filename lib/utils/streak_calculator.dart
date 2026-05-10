import 'package:projekt_grupowy/models/user/user_stats.dart';

/// Calculates and updates user streak based on game play history
class StreakCalculator {
  /// Calculate new streak based on last played date and current stats
  /// 
  /// Logic:
  /// - If played today: keep current streak
  /// - If played yesterday: increment streak
  /// - Otherwise (missed days): reset to 1
  static UserStats updateStreak(UserStats currentStats, DateTime gamePlayedAt) {
    final nowDay = DateTime(gamePlayedAt.year, gamePlayedAt.month, gamePlayedAt.day);
    
    int newStreak = 1;
    
    if (currentStats.lastPlayedAt != null) {
      final lastDay = DateTime(
        currentStats.lastPlayedAt!.year,
        currentStats.lastPlayedAt!.month,
        currentStats.lastPlayedAt!.day,
      );
      
      final lastDiffDays = nowDay.difference(lastDay).inDays;
      
      if (lastDiffDays == 0) {
        // Played today already, keep current streak (or set to 1 if it was 0)
        newStreak = (currentStats.currentStreak == 0) ? 1 : currentStats.currentStreak;
      } else if (lastDiffDays == 1) {
        // Played yesterday, increment streak
        newStreak = currentStats.currentStreak + 1;
      } else {
        // Missed days or first play, reset to 1
        newStreak = 1;
      }
    }
    
    // Return updated stats with new streak and last played date
    return currentStats.copyWith(
      currentStreak: newStreak,
      lastPlayedAt: gamePlayedAt,
    );
  }

  /// Update stats with game score
  static UserStats addGameScore(UserStats stats, int score) {
    return stats.copyWith(
      totalPoints: stats.totalPoints + score,
    );
  }
}
