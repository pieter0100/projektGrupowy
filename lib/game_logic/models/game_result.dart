import '../../models/level/stage_result.dart';

class GameResult {
  final String sessionId;
  final String uid;
  final DateTime timestamp;
  final List<StageResult> stageResults;
  final int score;
  final String gameType;
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
