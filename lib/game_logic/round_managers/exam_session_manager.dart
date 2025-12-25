import 'package:projekt_grupowy/game_logic/round_managers/game_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/services/question_provider.dart';

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

  /*
  if the set of questions is provided by QuestionProvider, assume the function is called getTypedQuestionsSet
  @override
  List<GameStage> generateStages(LevelInfo level) {
    final stages = <GameStage>[];
    _correctCount = 0;

    // Get a shuffled set of 10 unique questions for the exam
    final questions = QuestionProvider.getTypedQuestionsSet(level.levelNumber);

    for (final questionTyped in questions) {
      final data = TypedData(
        question: questionTyped.prompt,
        correctAnswer: int.parse(questionTyped.correctAnswer),
      );
      stages.add(GameStage(type: StageType.typed, data: data));
    }

    return stages;
  }
  */
  
  @override
  bool canSkipStage() {
    return false;
  }
  
  @override
  bool shouldFinish() {
    return completedCount >= _totalStagesCount;
  }

  
  /// Generates Typed stage data using QuestionProvider.
  TypedData _generateTypedData(LevelInfo level) {
    final questionTyped = QuestionProvider.getTypedQuestion(level: level.levelNumber);
    
    return TypedData(
      question: questionTyped.prompt,
      correctAnswer: int.parse(questionTyped.correctAnswer),
    );
  }
}
