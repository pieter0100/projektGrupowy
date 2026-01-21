/// Represents the result of a single stage in a game session.
class StageResult {
  final bool isCorrect;
  final bool skipped;
  final int? answerTime;
  final dynamic userAnswer;

  StageResult({
    required this.isCorrect,
    this.skipped = false,
    this.answerTime,
    this.userAnswer,
  });

  factory StageResult.skipped() {
    return StageResult(
      isCorrect: false,
      skipped: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isCorrect': isCorrect,
      'skipped': skipped,
      'answerTime': answerTime,
      'userAnswer': userAnswer,
    };
  }

  static StageResult fromMap(Map<String, dynamic> map) {
    return StageResult(
      isCorrect: map['isCorrect'] ?? false,
      skipped: map['skipped'] ?? false,
      answerTime: map['answerTime'],
      userAnswer: map['userAnswer'],
    );
  }
}
