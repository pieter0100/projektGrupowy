import 'package:projekt_grupowy/game_logic/round_managers/game_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';

class ExamSessionManager extends GameSessionManager {
  
  static const int _totalStagesCount = 10;
  
  int _correctCount = 0;
  
  int get correctCount => _correctCount;
  
  double getAccuracy() {
    if (totalCount == 0) return 0.0;
    return _correctCount / totalCount;
  }
  
  @override
  List<GameStage> generateStages(LevelInfo level) {
    final stages = <GameStage>[];
    _correctCount = 0;
    
    for (int i = 0; i < _totalStagesCount; i++) {
      final data = _generateTypedData(level);
      stages.add(GameStage(type: StageType.typed, data: data));
    }
    
    return stages;
  }
  
  @override
  bool canSkipStage() {
    return false;
  }
  
  @override
  bool shouldFinish() {
    return completedCount >= _totalStagesCount;
  }
  
  @override
  void processStageResult(StageResult result) {
    if (result.isCorrect) {
      _correctCount++;
    }
    super.processStageResult(result);
  }
  
  /// Generates Typed stage data using QuestionProvider.
  TypedData _generateTypedData(LevelInfo level) {
    final questionTyped = QuestionProvider.getTypedQuestion(level: level.levelNumber);
    
    return TypedData(
      question: questionTyped.prompt,
      correctAnswer: int.parse(questionTyped.correctAnswer),
    );
  }

  /// Saves the exam result to local storage. 
  // requires 100% accuracy to mark level as completed.
  Future<void> saveExamResult(String userId, LevelInfo level) async {
    if (!isFinished) {
      throw StateError('Cannot save exam result before session is finished');
    }

    final score = correctCount; // Score is the number of correct answers (max 10)
    final passed = correctCount == _totalStagesCount; // Must have 100% to pass

    // Get existing progress or create new one
    final existingProgress = LocalSaves.getLevelProgress(userId, level.levelId);
    final shouldSetFirstCompletion = existingProgress != null && passed && !existingProgress.completed;

    final newProgress = existingProgress != null
        ? existingProgress.copyWith(
            bestScore: score > existingProgress.bestScore ? score : existingProgress.bestScore,
            attempts: existingProgress.attempts + 1,
            completed: passed ? true : existingProgress.completed,
            updateFirstCompletedAt: shouldSetFirstCompletion,
            firstCompletedAt: shouldSetFirstCompletion ? DateTime.now() : existingProgress.firstCompletedAt,
            updateLastPlayedAt: true,
            lastPlayedAt: DateTime.now(),
          )
        : LevelProgress(
            levelId: level.levelId,
            bestScore: score,
            bestTimeSeconds: 0, // Time tracking not implemented yet
            attempts: 1,
            completed: passed,
            firstCompletedAt: passed ? DateTime.now() : null,
            lastPlayedAt: DateTime.now(),
          );

    await LocalSaves.saveLevelProgress(userId, newProgress);
  }
}
