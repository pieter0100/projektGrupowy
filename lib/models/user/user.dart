import 'package:hive/hive.dart';
import 'user_profile.dart';
import 'user_stats.dart';

part '../generated/user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final UserProfile profile;

  @HiveField(2)
  final UserStats stats;

  User({
    required this.userId,
    required this.profile,
    required this.stats,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profile': profile.toJson(),
      'stats': stats.toJson(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  User copyWith({
    String? userId,
    UserProfile? profile,
    UserStats? stats,
  }) {
    return User(
      userId: userId ?? this.userId,
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, profile: $profile, stats: $stats)';
  }
}