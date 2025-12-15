import 'dart:math';
import 'package:projekt_grupowy/game_logic/round_managers/game_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/services/card_generator.dart';
import 'package:projekt_grupowy/services/question_provider.dart';


class PracticeSessionManager extends GameSessionManager {
  
  static const int _totalStagesCount = 6;
  static const int _pairsAmount = 3;
  
  // for anti-series logic
  final List<StageType> _typeHistory = [];
  final Random _random = Random();
  
  @override
  List<GameStage> generateStages(LevelInfo level) {
    final stages = <GameStage>[];
    _typeHistory.clear();
    
    for (int i = 0; i < _totalStagesCount; i++) {
      final type = _selectNextType();
      final data = _generateStageData(type, level);
      stages.add(GameStage(type: type, data: data));
    }
    
    return stages;
  }
  
  @override
  bool canSkipStage() {
    return currentType == StageType.typed;
  }
  
  @override
  bool shouldFinish() {
    return completedCount >= _totalStagesCount;
  }
  
  @override
  void processStageResult(StageResult result) {
    // practice mode doesn't need special processing
    super.processStageResult(result);
  }

  StageType _selectNextType() {
    final available = [
      StageType.multipleChoice,
      StageType.typed,
      StageType.pairs,
    ];
    
    if (_typeHistory.length >= 2 &&
        _typeHistory[_typeHistory.length - 1] == _typeHistory[_typeHistory.length - 2]) {
      available.remove(_typeHistory.last);
    }
    
    final selected = available[_random.nextInt(available.length)];
    _typeHistory.add(selected);
    
    return selected;
  }
  
  StageData _generateStageData(StageType type, LevelInfo level) {
    switch (type) {
      case StageType.multipleChoice:
        return _generateMultipleChoiceData(level);
      case StageType.typed:
        return _generateTypedData(level);
      case StageType.pairs:
        return _generatePairsData(level);
    }
  }
  
  /// Generates Multiple Choice stage data using QuestionProvider.
  MultipleChoiceData _generateMultipleChoiceData(LevelInfo level) {
    final questionMC = QuestionProvider.getMcQuestion(level: level.levelNumber);
    
    // Parse string options to int list
    final options = questionMC.options.map((opt) => int.parse(opt)).toList();
    final correctAnswer = int.parse(questionMC.options[questionMC.correctIndex]);
    
    return MultipleChoiceData(
      question: questionMC.prompt,
      correctAnswer: correctAnswer,
      options: options,
    );
  }
  
  /// Generates Typed stage data using QuestionProvider.
  TypedData _generateTypedData(LevelInfo level) {
    final questionTyped = QuestionProvider.getTypedQuestion(level: level.levelNumber);
    
    return TypedData(
      question: questionTyped.prompt,
      correctAnswer: int.parse(questionTyped.correctAnswer),
    );
  }
  
  /// Generates Pairs stage data using CardGenerator.
  PairsData _generatePairsData(LevelInfo level) {
    // Generate random multiplication table (1-10)
    final typeOfMultiplication = _random.nextInt(10) + 1;
    
    final questions = QuestionProvider.getPairsQuestions(
      level: typeOfMultiplication,
      pairsAmount: _pairsAmount,
    );
    
    final cardGenerator = CardGenerator(questions: questions);
    
    return PairsData(
      cards: cardGenerator.cardsDeck,
      pairsCount: _pairsAmount,
      typeOfMultiplication: typeOfMultiplication,
    );
  }
}
