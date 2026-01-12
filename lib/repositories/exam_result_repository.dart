import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';

class ExamResultRepository {
  /// Saves the exam result to local storage.
  /// Requires 100% accuracy to mark level as completed.
  Future<void> saveExamResult({
    required String userId,
    required LevelInfo level,
    required int correctCount,
    required int totalStagesCount,
    required bool isFinished,
  }) async {
    if (!isFinished) {
      throw StateError('Cannot save exam result before session is finished');
    }

    final score = correctCount;
    final passed = correctCount == totalStagesCount;

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
            bestTimeSeconds: 0,
            attempts: 1,
            completed: passed,
            firstCompletedAt: passed ? DateTime.now() : null,
            lastPlayedAt: DateTime.now(),
          );

    await LocalSaves.saveLevelProgress(userId, newProgress);
  }
}
