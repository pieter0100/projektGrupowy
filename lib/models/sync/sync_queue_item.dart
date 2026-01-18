class SyncQueueItem {
  final String sessionId;
  final String type; // 'result' or 'progress'
  final String uid;
  final DateTime enqueuedAt;

  SyncQueueItem({
    required this.sessionId,
    required this.type,
    required this.uid,
    required this.enqueuedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'type': type,
      'uid': uid,
      'enqueuedAt': enqueuedAt.toIso8601String(),
    };
  }

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      sessionId: map['sessionId'] as String,
      type: map['type'] as String,
      uid: map['uid'] as String,
      enqueuedAt: DateTime.parse(map['enqueuedAt'] as String),
    );
  }
}
