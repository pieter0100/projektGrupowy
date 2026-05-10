import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekt_grupowy/game_logic/round_managers/game_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/services/achievement_service.dart';

class ExamSessionManager extends GameSessionManager {
  static const int _totalStagesCount = 10;

  int _correctCount = 0;

  int get correctCount => _correctCount;

  double getAccuracy() {
    if (totalCount == 0) return 0.0;
    return _correctCount / totalCount;
  }

  @override
  void processStageResult(result) {
    if (result.isCorrect == true) {
      _correctCount++;
    }
    super.processStageResult(result);
  }

  @override
  List<GameStage> generateStages(LevelInfo level) {
    final stages = <GameStage>[];
    _correctCount = 0;

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

    // Grant achievements and rewards if passed
    if (isPassed) {
      // 1. Grant Achievements
      await AchievementService.checkAndGrantLevelAchievement(userId, int.parse(levelId));
      await AchievementService.checkAndGrantExamMaster(userId, correctCount);

      // 2. Grant EXP (Points)
      final levelInfo = LocalSaves.getLevel(levelId);
      final user = LocalSaves.getUser(userId);
      
      if (levelInfo != null && user != null) {
        final newStats = user.stats.copyWith(
          totalPoints: user.stats.totalPoints + levelInfo.rewards.points,
          totalGamesPlayed: user.stats.totalGamesPlayed + 1,
        );
        final updatedUser = user.copyWith(stats: newStats);
        
        // Save locally
        await LocalSaves.saveUser(updatedUser);
        
        // Sync to Firestore
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set(updatedUser.toJson(), SetOptions(merge: true));
          print('📈 XP GRANTED AND SYNCED: +${levelInfo.rewards.points} points');
        } catch (e) {
          print('⚠️ Failed to sync XP to Firestore: $e');
        }
      }
    }
  }
}
