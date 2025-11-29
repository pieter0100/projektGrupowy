import 'package:hive/hive.dart';

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

  UserStats({
    required this.totalGamesPlayed,
    required this.totalPoints,
    required this.currentStreak,
    required this.lastPlayedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalGamesPlayed: json['totalGamesPlayed'],
      totalPoints: json['totalPoints'],
      currentStreak: json['currentStreak'],
      lastPlayedAt: DateTime.parse(json['lastPlayedAt']),
    );
  }

  UserStats copyWith({
    int? totalGamesPlayed,
    int? totalPoints,
    int? currentStreak,
    DateTime? lastPlayedAt,
  }) {
    return UserStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  String toString() {
    return 'UserStats(totalGamesPlayed: $totalGamesPlayed, totalPoints: $totalPoints, currentStreak: $currentStreak, lastPlayedAt: $lastPlayedAt)';
  }
}