class GameProgress {
  final String sessionId;
  final String uid;
  final String gameId;
  final int completedCount;
  final int totalCount;
  final DateTime lastUpdated;
  bool syncPending;

  GameProgress({
    required this.sessionId,
    required this.uid,
    required this.gameId,
    required this.completedCount,
    required this.totalCount,
    required this.lastUpdated,
    this.syncPending = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'uid': uid,
      'gameId': gameId,
      'completedCount': completedCount,
      'totalCount': totalCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'syncPending': syncPending,
    };
  }

  static GameProgress fromMap(Map<String, dynamic> map) {
    return GameProgress(
      sessionId: map['sessionId'],
      uid: map['uid'],
      gameId: map['gameId'],
      completedCount: map['completedCount'],
      totalCount: map['totalCount'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
      syncPending: map['syncPending'] ?? false,
    );
  }
}
