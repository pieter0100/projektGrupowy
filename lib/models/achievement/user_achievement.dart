import 'package:hive/hive.dart';

part 'user_achievement.g.dart';

@HiveType(typeId: 20)
class UserAchievement {
  @HiveField(0)
  final String achievementId;

  @HiveField(1)
  final DateTime earnedAt;

  UserAchievement({
    required this.achievementId,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      achievementId: json['achievementId'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
    );
  }
}
