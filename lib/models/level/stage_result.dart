/// Represents the result of a single stage in a game session.
class StageResult {
  final bool isCorrect;
  
  final bool skipped;
  
  //  (optional)
  final int? answerTime;
  
  // User's answer (dynamic type to support various answer formats)
  final dynamic userAnswer;
  
  StageResult({
    required this.isCorrect,
    this.skipped = false,
    this.answerTime,
    this.userAnswer,
  });
  
  factory StageResult.skipped() { 
    // factory constructor allows creating a skipped result easily
    // StageResult.skipped() instead of StageResult(isCorrect: false, skipped: true)
    return StageResult(
      isCorrect: false,
      skipped: true,
    );
  }
}
