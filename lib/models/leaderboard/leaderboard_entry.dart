import 'package:hive/hive.dart';

part 'leaderboard_entry.g.dart';

@HiveType(typeId: 8)
class LeaderboardEntry {
  @HiveField(0)
  final String playerId;

  @HiveField(1)
  final String playerName;

  @HiveField(2)
  final int streak;

  @HiveField(3)
  final DateTime dateAchieved;

  LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    required this.streak,
    required this.dateAchieved,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'streak': streak,
      'dateAchieved': dateAchieved.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      streak: json['streak'] as int,
      dateAchieved: DateTime.parse(json['dateAchieved'] as String),
    );
  }

  LeaderboardEntry copyWith({
    String? playerId,
    String? playerName,
    int? streak,
    DateTime? dateAchieved,
  }) {
    return LeaderboardEntry(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      streak: streak ?? this.streak,
      dateAchieved: dateAchieved ?? this.dateAchieved,
    );
  }

  @override
  String toString() {
    return 'LeaderboardEntry(playerId: $playerId, playerName: $playerName, streak: $streak, dateAchieved: $dateAchieved)';
  }
}
