import 'package:hive/hive.dart';
import '../achievement/achievement.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 1)
class UserStats {
  @HiveField(0)
  final int totalGamesPlayed;

  @HiveField(1)
  final int totalPoints;

  @HiveField(2)
  final int currentStreak;

  @HiveField(3)
  final DateTime lastPlayedAt;

  @HiveField(4)
  final List<Achievement> achievements;

  UserStats({
    required this.totalGamesPlayed,
    required this.totalPoints,
    required this.currentStreak,
    required this.lastPlayedAt,
    this.achievements = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null 
          ? DateTime.parse(json['lastPlayedAt']) 
          : DateTime.now(),
      achievements: (json['achievements'] as List?)
          ?.map((a) => Achievement.fromJson(a as Map<String, dynamic>))
          .toList() ?? const [],
    );
  }

  UserStats copyWith({
    int? totalGamesPlayed,
    int? totalPoints,
    int? currentStreak,
    DateTime? lastPlayedAt,
    List<Achievement>? achievements,
  }) {
    return UserStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  String toString() {
    return 'UserStats(totalGamesPlayed: $totalGamesPlayed, totalPoints: $totalPoints, currentStreak: $currentStreak, achievements: ${achievements.length})';
  }
}