import 'package:hive/hive.dart';
import '../../models/level/stage_result.dart';

part 'game_result.g.dart';

@HiveType(typeId: 20)
class GameResult {
  @HiveField(0)
  final String sessionId;
  @HiveField(1)
  final String uid;
  @HiveField(2)
  final DateTime timestamp;
  @HiveField(3)
  final List<StageResult> stageResults;
  @HiveField(4)
  final int score;
  @HiveField(5)
  final String gameType;
  @HiveField(6)
  bool syncPending;

  GameResult({
    required this.sessionId,
    required this.uid,
    required this.timestamp,
    required this.stageResults,
    required this.score,
    required this.gameType,
    this.syncPending = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'uid': uid,
      'timestamp': timestamp.toIso8601String(),
      'stageResults': stageResults.map((r) => r.toMap()).toList(),
      'score': score,
      'gameType': gameType,
      'syncPending': syncPending,
    };
  }

  static GameResult fromMap(Map<String, dynamic> map) {
    return GameResult(
      sessionId: map['sessionId'],
      uid: map['uid'],
      timestamp: DateTime.parse(map['timestamp']),
      stageResults: (map['stageResults'] as List)
          .map((r) => StageResult.fromMap(r)).toList(),
      score: map['score'],
      gameType: map['gameType'],
      syncPending: map['syncPending'] ?? false,
    );
  }
}
