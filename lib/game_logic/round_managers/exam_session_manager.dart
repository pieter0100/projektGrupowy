import 'package:projekt_grupowy/game_logic/round_managers/game_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/game_logic/models/game_result.dart';
import 'package:projekt_grupowy/services/results_service.dart';

class ExamSessionManager extends GameSessionManager {
  static const int _totalStagesCount = 10;

  int _correctCount = 0;
  int _totalPoints = 0;
  final ResultsService? _resultsService;

  ExamSessionManager({ResultsService? resultsService}) : _resultsService = resultsService;

  int get correctCount => _correctCount;

  int get totalPoints => _totalPoints;

  double getAccuracy() {
    if (totalCount == 0) return 0.0;
    return _correctCount / totalCount;
  }

  @override
  void processStageResult(result) {
    if (result.isCorrect == true) {
      _correctCount++;
    }
    // Note: Do NOT add points during exam - points awarded only on completion
    super.processStageResult(result);
  }

  @override
  List<GameStage> generateStages(LevelInfo level) {
    final stages = <GameStage>[];
    _correctCount = 0;
    _totalPoints = 0;

    // Get a shuffled set of 10 unique questions for the exam
    final questions = QuestionProvider.getTypedQuestionsSet(
      level: level.levelNumber,
    );

    for (final questionTyped in questions) {
      final data = TypedData(
        question: questionTyped.prompt,
        correctAnswer: int.parse(questionTyped.correctAnswer),
      );
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

  Future<void> saveProgress(String userId, String levelId) async {
    final bool isPassed = correctCount == 10;

    final existingProgress = LocalSaves.getLevelProgress(userId, levelId);

    final int newAttempts = (existingProgress?.attempts ?? 0) + 1;
    final int currentBestScore = existingProgress?.bestScore ?? 0;
    final int newBestScore = correctCount > currentBestScore
        ? correctCount
        : currentBestScore;
    final bool wasCompleted = existingProgress?.completed ?? false;

    // Award 100 points ONLY if finishing level (10/10) with best score
    if (isPassed && correctCount > currentBestScore) {
      _totalPoints = 100;
    } else {
      _totalPoints = 0;
    }

    DateTime? firstCompleted;
    if (existingProgress?.firstCompletedAt != null) {
      firstCompleted = existingProgress!.firstCompletedAt;
    } else if (isPassed) {
      firstCompleted = DateTime.now();
    }

    final newProgress = LevelProgress(
      levelId: levelId,
      bestScore: newBestScore,
      bestTimeSeconds: 0,
      attempts: newAttempts,
      completed: wasCompleted || isPassed,
      firstCompletedAt: firstCompleted,
      lastPlayedAt: DateTime.now(),
    );

    await LocalSaves.saveLevelProgress(userId, newProgress);

    // Sync LevelProgress to Firestore
    if (_resultsService != null) {
      await _resultsService!.saveLevelProgress(userId, newProgress);
    }

    // Update user stats locally (offline-first)
    final user = LocalSaves.getUser(userId);
    if (user != null) {
      final updatedStats = user.stats.copyWith(
        totalGamesPlayed: user.stats.totalGamesPlayed + 1,
        totalPoints: user.stats.totalPoints + totalPoints,
        lastPlayedAt: DateTime.now(),
      );
      await LocalSaves.updateUserStats(userId, updatedStats);
    }

    // Create GameResult for Firebase sync
    // This will be saved via ResultsService (if provided)
    // The onResultWrite Cloud Function will then update users/{uid}/stats.totalPoints
    final gameResult = GameResult(
      sessionId: 'exam_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      uid: userId,
      timestamp: DateTime.now(),
      stageResults: stageResults,
      score: totalPoints,
      gameType: 'Typed',
    );

    // Save to offline store and queue for Firebase sync
    if (_resultsService != null) {
      await _resultsService.saveResult(gameResult);
    }
  }
}
