import 'package:hive/hive.dart';
import 'leaderboard_entry.dart';

part 'leaderboard.g.dart';

@HiveType(typeId: 9)
class Leaderboard {
  @HiveField(0)
  final List<LeaderboardEntry> entries;

  @HiveField(1)
  final DateTime lastUpdated;

  Leaderboard({
    required this.entries,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      entries: (json['entries'] as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Leaderboard copyWith({
    List<LeaderboardEntry>? entries,
    DateTime? lastUpdated,
  }) {
    return Leaderboard(
      entries: entries ?? this.entries,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'Leaderboard(entries: ${entries.length} entries, lastUpdated: $lastUpdated)';
  }
}
