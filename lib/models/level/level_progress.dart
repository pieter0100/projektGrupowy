import 'package:hive/hive.dart';

part '../generated/level_progress.g.dart';

@HiveType(typeId: 4)
class LevelProgress {
  @HiveField(0)
  final String levelId;

  @HiveField(1)
  final int bestScore;

  @HiveField(2)
  final int bestTimeSeconds;

  @HiveField(3)
  final int attempts;

  @HiveField(4)
  final bool completed;

  @HiveField(5)
  final DateTime? firstCompletedAt;

  @HiveField(6)
  final DateTime? lastPlayedAt;

  LevelProgress({
    required this.levelId,
    required this.bestScore,
    required this.bestTimeSeconds,
    required this.attempts,
    required this.completed,
    this.firstCompletedAt,
    this.lastPlayedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'bestScore': bestScore,
      'bestTimeSeconds': bestTimeSeconds,
      'attempts': attempts,
      'completed': completed,
      'firstCompletedAt': firstCompletedAt?.toIso8601String(),
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelId: json['levelId'] as String,
      bestScore: json['bestScore'] as int,
      bestTimeSeconds: json['bestTimeSeconds'] as int,
      attempts: json['attempts'] as int,
      completed: json['completed'] as bool,
      firstCompletedAt: json['firstCompletedAt'] != null
          ? DateTime.parse(json['firstCompletedAt'] as String)
          : null,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'] as String)
          : null,
    );
  }

  LevelProgress copyWith({
    String? levelId,
    int? bestScore,
    int? bestTimeSeconds,
    int? attempts,
    bool? completed,
    bool updateFirstCompletedAt = false,
    DateTime? firstCompletedAt,
    bool updateLastPlayedAt = false,
    DateTime? lastPlayedAt,
  }) {
    return LevelProgress(
      levelId: levelId ?? this.levelId,
      bestScore: bestScore ?? this.bestScore,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      attempts: attempts ?? this.attempts,
      completed: completed ?? this.completed,
      firstCompletedAt: updateFirstCompletedAt ? firstCompletedAt : this.firstCompletedAt,
      lastPlayedAt: updateLastPlayedAt ? lastPlayedAt : this.lastPlayedAt,
    );
  }

  @override
  String toString() {
    return 'LevelProgress(levelId: $levelId, bestScore: $bestScore, bestTimeSeconds: $bestTimeSeconds, attempts: $attempts, completed: $completed, firstCompletedAt: $firstCompletedAt, lastPlayedAt: $lastPlayedAt)';
  }
}
