import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/user/user.dart' as model;
import '../models/achievement/user_achievement.dart';
import '../game_logic/local_saves.dart';

class AchievementService {
  static Future<void> checkAndGrantLevelAchievement(String userId, int level) async {
    final achievementId = 'multiply_${level}_complete';
    await _grantAchievement(userId, achievementId);
  }

  static Future<void> checkAndGrantExamMaster(String userId, int score) async {
    if (score == 10) {
      await _grantAchievement(userId, 'exam_master');
    }
  }

  static Future<void> _grantAchievement(String userId, String achievementId) async {
    try {
      final usersBox = Hive.box<model.User>(LocalSaves.usersBoxName);
      final user = usersBox.get(userId);

      if (user == null) return;

      // Check if already earned
      final alreadyEarned = user.earnedAchievements?.any((a) => a.achievementId == achievementId) ?? false;
      if (alreadyEarned) return;

      // Add new achievement
      final newAchievement = UserAchievement(
        achievementId: achievementId,
        earnedAt: DateTime.now(),
      );

      final currentAchievements = user.earnedAchievements ?? [];
      final updatedAchievements = List<UserAchievement>.from(currentAchievements)..add(newAchievement);

      final updatedUser = user.copyWith(earnedAchievements: updatedAchievements);
      
      // 1. Zapis lokalny
      await LocalSaves.saveUser(updatedUser);

      // 2. Synchronizacja z Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(updatedUser.toJson(), SetOptions(merge: true));
        print('🏆 ACHIEVEMENT UNLOCKED AND SYNCED: $achievementId for user $userId');
      } catch (e) {
        print('⚠️ Achievement synced failed to Firestore, but saved locally: $e');
      }
    } catch (e) {
      print('🔥 Critical error granting achievement: $e');
    }
  }
}
