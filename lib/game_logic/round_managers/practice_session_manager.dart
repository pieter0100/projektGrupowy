import 'dart:math';
import 'package:projekt_grupowy/game_logic/round_managers/game_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/services/card_generator.dart';
import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';

class PracticeSessionManager extends GameSessionManager {
  static const int _totalStagesCount = 6;
  static const int _pairsAmount = 3;
  static const int _pointsPerCorrectAnswer = 5;

  int _correctCount = 0;
  int _totalPoints = 0;

  @override
  int get totalCount => _totalStagesCount;

  int get correctCount => _correctCount;
  int get totalPoints => _totalPoints;

  // for anti-series logic
  final List<StageType> _typeHistory = [];
  final Random _random = Random();
  LevelInfo? _currentLevel;

  @override
  void start(LevelInfo level) {
    _currentLevel = level;
    _typeHistory.clear();
    _correctCount = 0;
    _totalPoints = 0;
    super.start(level);
  }

  @override
  void processStageResult(StageResult result) {
    if (result.isCorrect == true) {
      _correctCount++;
      _totalPoints += _pointsPerCorrectAnswer;
    }
    super.processStageResult(result);
  }

  @override
  void nextStage(StageResult result) {
    if (result.skipped || !result.isCorrect) {
      final type = selectNextType();
      final data = generateStageData(type, _currentLevel!);
      stages.add(GameStage(type: type, data: data));
      super.nextStage(StageResult.skipped());
    } else {
      super.nextStage(result);
    }
  }

  @override
  double getProgress() {
    return completedCount / _totalStagesCount;
  }

  @override
  bool shouldFinish() {
    return completedCount >= _totalStagesCount;
  }

  @override
  List<GameStage> generateStages(LevelInfo level) {
    final stages = <GameStage>[];
    _typeHistory.clear();

    for (int i = 0; i < _totalStagesCount; i++) {
      final type = selectNextType();
      final data = generateStageData(type, level);
      stages.add(GameStage(type: type, data: data));
    }

    return stages;
  }

  @override
  bool canSkipStage() {
    return currentType == StageType.typed;
  }

  StageType selectNextType() {
    final available = [
      StageType.multipleChoice,
      StageType.typed,
      StageType.pairs,
    ];
    // anti-series: avoid repeating the same type more than twice in a row
    if (_typeHistory.length >= 2 &&
        _typeHistory[_typeHistory.length - 1] ==
            _typeHistory[_typeHistory.length - 2]) {
      available.remove(_typeHistory.last);
    }

    final selected = available[_random.nextInt(available.length)];
    _typeHistory.add(selected);

    return selected;
  }

  StageData generateStageData(StageType type, LevelInfo level) {
    switch (type) {
      case StageType.multipleChoice:
        return generateMultipleChoiceData(level);
      case StageType.typed:
        return generateTypedData(level);
      case StageType.pairs:
        return generatePairsData(level);
    }
  }

  /// Generates Multiple Choice stage data using QuestionProvider.
  MultipleChoiceData generateMultipleChoiceData(LevelInfo level) {
    final questionMC = QuestionProvider.getMcQuestion(level: level.levelNumber);

    // Parse string options to int list
    try {
      final options = questionMC.options.map((opt) => int.parse(opt)).toList();
      final correctAnswer = int.parse(
        questionMC.options[questionMC.correctIndex],
      );

      return MultipleChoiceData(
        question: questionMC.prompt,
        correctAnswer: correctAnswer,
        options: options,
      );
    } on FormatException catch (e) {
      throw FormatException(
        'Invalid question data for level ${level.levelNumber}: '
        'Multiple choice options must be valid integers. Error: ${e.message}',
      );
    }
  }

  /// Generates Typed stage data using QuestionProvider.
  TypedData generateTypedData(LevelInfo level) {
    final questionTyped = QuestionProvider.getTypedQuestion(
      level: level.levelNumber,
    );

    try {
      return TypedData(
        question: questionTyped.prompt,
        correctAnswer: int.parse(questionTyped.correctAnswer),
      );
    } on FormatException catch (e) {
      throw FormatException(
        'Invalid question data for level ${level.levelNumber}: '
        'Typed answer must be a valid integer. Error: ${e.message}',
      );
    }
  }

  /// Generates Pairs stage data using CardGenerator.
  PairsData generatePairsData(LevelInfo level) {
    try {
      final questions = QuestionProvider.getPairsQuestions(
        level: level.levelNumber,
        pairsAmount: _pairsAmount,
      );

      final cardGenerator = CardGenerator(questions: questions);

      return PairsData(
        cards: cardGenerator.cardsDeck,
        pairsCount: _pairsAmount,
        typeOfMultiplication: questions.typeOfMultiplication,
      );
    } catch (e) {
      throw Exception(
        'Failed to generate pairs data for level ${level.levelNumber}: $e',
      );
    }
  }

  /// Saves practice session progress to Hive and queues for Firebase sync.
  /// In practice mode, points are awarded per correct answer (5 points each).
  /// No "best score" restriction like exam mode - all correct answers earn points.
  Future<void> saveProgress(String userId, String levelId) async {
    // Update local user stats with earned points
    final user = LocalSaves.getUser(userId);
    if (user != null) {
      final updatedStats = user.stats.copyWith(
        totalGamesPlayed: user.stats.totalGamesPlayed + 1,
        totalPoints: user.stats.totalPoints + _totalPoints,
        lastPlayedAt: DateTime.now(),
      );
      await LocalSaves.updateUserStats(userId, updatedStats);
    }

    // TODO: Create GameResult for Firebase sync when ResultsService is ready
    // The onResultWrite Cloud Function will then update users/{uid}/stats.totalPoints
    // final gameResult = GameResult(
    //   sessionId: 'practice_${userId}_${DateTime.now().millisecondsSinceEpoch}',
    //   uid: userId,
    //   timestamp: DateTime.now(),
    //   stageResults: stageResults,
    //   score: _totalPoints,
    //   gameType: 'Practice',
    // );
  }
}
