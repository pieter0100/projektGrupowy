import 'package:projekt_grupowy/game_logic/round_managers/game_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/game_logic/models/game_result.dart';

class ExamSessionManager extends GameSessionManager {
  static const int _totalStagesCount = 10;
  static const int _pointsPerCorrectAnswer = 5;

  int _correctCount = 0;
  int _totalPoints = 0;

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
      _totalPoints += _pointsPerCorrectAnswer;
    }
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
    // This should be saved via ResultsService (injected in the app)
    // The onResultWrite Cloud Function will then update users/{uid}/stats.totalPoints
    final gameResult = GameResult(
      sessionId: 'exam_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      uid: userId,
      timestamp: DateTime.now(),
      stageResults: stageResults,
      score: totalPoints,
      gameType: 'Typed',
    );

    // Store for access by UI/app to sync to Firebase
    // The app should use: ResultsService.saveResult(gameResult)
    // which will enqueue it for Firebase sync via SyncService
  }
}
