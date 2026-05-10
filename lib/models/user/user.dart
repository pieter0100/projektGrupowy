import 'package:hive/hive.dart';
import '../achievement/user_achievement.dart';
import 'user_profile.dart';
import 'user_stats.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final UserProfile profile;

  @HiveField(2)
  final UserStats stats;

  @HiveField(3)
  final List<UserAchievement>? earnedAchievements;

  User({
    required this.userId,
    required this.profile,
    required this.stats,
    List<UserAchievement>? earnedAchievements,
  }) : earnedAchievements = earnedAchievements ?? const [];

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profile': profile.toJson(),
      'stats': stats.toJson(),
      'earnedAchievements': earnedAchievements?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      earnedAchievements: (json['earnedAchievements'] as List? ?? [])
          .map((e) => UserAchievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  User copyWith({
    String? userId,
    UserProfile? profile,
    UserStats? stats,
    List<UserAchievement>? earnedAchievements,
  }) {
    return User(
      userId: userId ?? this.userId,
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      earnedAchievements: earnedAchievements ?? this.earnedAchievements,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, profile: $profile, stats: $stats)';
  }
}