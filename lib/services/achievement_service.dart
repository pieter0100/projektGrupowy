import 'package:projekt_grupowy/models/achievement/achievement.dart';
import 'package:projekt_grupowy/models/user/user_stats.dart';
import 'package:projekt_grupowy/game_logic/models/game_result.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';

class AchievementService {
  static const String EXAM_MASTER = 'exam_master';

  /// Checks for new achievements after a game result
  static List<Achievement> checkGameAchievements(
    GameResult result,
    UserStats currentStats,
  ) {
    final List<Achievement> newAchievements = List.from(currentStats.achievements);
    bool changed = false;

    // 1. Check Exam Master: 10/10 in exam
    if (result.gameType == 'Typed' && result.score >= 10) {
      if (!newAchievements.any((a) => a.id == EXAM_MASTER)) {
        newAchievements.add(Achievement(
          id: EXAM_MASTER,
          title: 'Mistrz Egzaminów',
          description: 'Zdobądź 100% punktów w dowolnym egzaminie.',
          xpValue: 500,
          dateAchieved: DateTime.now(),
        ));
      }
    }

    // 2. Check Streak: streak_3_days
    if (currentStats.currentStreak >= 3) {
      const streakId = 'streak_3_days';
      if (!newAchievements.any((a) => a.id == streakId)) {
        newAchievements.add(Achievement(
          id: streakId,
          title: 'Wytrwały Uczeń',
          description: 'Utrzymaj serię nauki przez 3 dni z rzędu.',
          xpValue: 300,
          dateAchieved: DateTime.now(),
        ));
      }
    }

    return newAchievements;
  }

  /// Checks for new achievements after level progress update
  static List<Achievement> checkProgressAchievements(
    LevelProgress progress,
    UserStats currentStats,
  ) {
    final List<Achievement> newAchievements = List.from(currentStats.achievements);

    // Check for multiply_X_complete (X = 1..10)
    if (progress.completed) {
      // levelId format is likely just "1", "2", etc. or has a prefix
      // Strip prefix if exists, e.g., "level_1" -> "1"
      final levelNum = progress.levelId.replaceAll(RegExp(r'[^0-9]'), '');
      if (levelNum.isNotEmpty) {
        final String achievementId = 'multiply_${levelNum}_complete';
        
        if (!newAchievements.any((a) => a.id == achievementId)) {
          newAchievements.add(Achievement(
            id: achievementId,
            title: 'Poziom $levelNum Ukończony',
            description: 'Ukończono pomyślnie wszystkie etapy poziomu $levelNum.',
            xpValue: 100, // Standard reward for level completion
            dateAchieved: DateTime.now(),
          ));
        }
      }
    }

    return newAchievements;
  }
}
