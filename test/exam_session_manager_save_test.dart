import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/game_logic/round_managers/exam_session_manager.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';
import 'helpers/hive_test_helper.dart';

/// Integration tests for ExamSessionManager.saveExamResult()
/// 
/// These tests use HiveTestHelper for in-memory database testing.
/// Run with: flutter test test/exam_session_manager_save_test.dart
void main() {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  group('ExamSessionManager - saveExamResult (Integration)', () {
    late ExamSessionManager manager;
    late LevelInfo testLevel;
    const String testUserId = 'test-user-123';

    setUpAll(() async {
      // initialize Hive with test helper (no Flutter dependencies)
      await HiveTestHelper.init();
    });

    tearDownAll(() async {
      // clean up Hive after all tests
      await HiveTestHelper.cleanup();
    });

    setUp(() async {
      manager = ExamSessionManager();
      testLevel = LevelInfo(
        levelId: 'exam-test-level',
        levelNumber: 5,
        name: 'Test Exam Level',
        description: 'Test Exam Description',
        unlockRequirements: UnlockRequirements(
          minPoints: 0,
          previousLevelId: null,
        ),
        rewards: Rewards(points: 10),
        isRevision: false,
      );
      
      // clean up any existing progress for this test level
      final box = Hive.box<LevelProgress>(LocalSaves.levelProgressBoxName);
      await box.clear();
    });

    tearDown(() async {
      // clean up after each test
      final box = Hive.box<LevelProgress>(LocalSaves.levelProgressBoxName);
      await box.clear();
    });

    test('should throw StateError if session is not finished', () async {
      logger.i('Testing saveExamResult before session finished...');
      manager.start(testLevel);

      expect(
        () async => await manager.saveExamResult(testUserId, testLevel),
        throwsStateError,
      );

      logger.i('StateError correctly thrown');
    });

    test('should save result with 100% score and mark as completed', () async {
      logger.i('Testing perfect score save (10/10)...');
      manager.start(testLevel);

      // complete all 10 stages correctly
      for (int i = 0; i < 10; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.isFinished, isTrue);
      expect(manager.correctCount, equals(10));
      logger.i('Session finished with ${manager.correctCount}/10 correct');

      // Save the result
      await manager.saveExamResult(testUserId, testLevel);
      logger.i('Result saved to LocalSaves');

      // Verify saved progress
      final progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
      expect(progress, isNotNull);
      expect(progress!.bestScore, equals(10));
      expect(progress.completed, isTrue);
      expect(progress.attempts, equals(1));
      expect(progress.firstCompletedAt, isNotNull);
      expect(progress.lastPlayedAt, isNotNull);

      logger.i('═══════════════════════════════════════════════════');
      logger.i('LevelProgress after perfect score:');
      logger.i('  levelId: ${progress.levelId}');
      logger.i('  bestScore: ${progress.bestScore}/10');
      logger.i('  completed: ${progress.completed}');
      logger.i('  attempts: ${progress.attempts}');
      logger.i('  firstCompletedAt: ${progress.firstCompletedAt}');
      logger.i('  lastPlayedAt: ${progress.lastPlayedAt}');
      logger.i('  bestTimeSeconds: ${progress.bestTimeSeconds}');
      logger.i('═══════════════════════════════════════════════════');
    });

    test('should save result with less than 100% and NOT mark as completed', () async {
      logger.i('Testing incomplete score save (7/10)...');
      manager.start(testLevel);

      // complete 7 correct, 3 incorrect
      for (int i = 0; i < 7; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }
      for (int i = 0; i < 3; i++) {
        manager.nextStage(StageResult(isCorrect: false));
      }

      expect(manager.isFinished, isTrue);
      expect(manager.correctCount, equals(7));
      logger.i('Session finished with ${manager.correctCount}/10 correct');

      // save the result
      await manager.saveExamResult(testUserId, testLevel);
      logger.i('Result saved to LocalSaves');

      // verify saved progress
      final progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
      expect(progress, isNotNull);
      expect(progress!.bestScore, equals(7));
      expect(progress.completed, isFalse);
      expect(progress.attempts, equals(1));
      expect(progress.firstCompletedAt, isNull); // not completed, so no completion date
      expect(progress.lastPlayedAt, isNotNull);

      logger.i('═══════════════════════════════════════════════════');
      logger.i('LevelProgress after incomplete score (7/10):');
      logger.i('  levelId: ${progress.levelId}');
      logger.i('  bestScore: ${progress.bestScore}/10');
      logger.i('  completed: ${progress.completed}');
      logger.i('  attempts: ${progress.attempts}');
      logger.i('  firstCompletedAt: ${progress.firstCompletedAt}');
      logger.i('  lastPlayedAt: ${progress.lastPlayedAt}');
      logger.i('  bestTimeSeconds: ${progress.bestTimeSeconds}');
      logger.i('═══════════════════════════════════════════════════');
    });

    test('should update best score on subsequent attempts', () async {
      logger.i('Testing best score update on multiple attempts...');

      // first attempt: 6/10
      logger.i('\n--- ATTEMPT 1: 6/10 ---');
      manager.start(testLevel);
      for (int i = 0; i < 6; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }
      for (int i = 0; i < 4; i++) {
        manager.nextStage(StageResult(isCorrect: false));
      }
      logger.i('Session finished with ${manager.correctCount}/10 correct');
      await manager.saveExamResult(testUserId, testLevel);

      var progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
      expect(progress!.bestScore, equals(6));
      expect(progress.attempts, equals(1));
      expect(progress.completed, isFalse);
      logger.i('LevelProgress after attempt 1:');
      logger.i('  bestScore: ${progress.bestScore}, attempts: ${progress.attempts}, completed: ${progress.completed}');

      // second attempt: 8/10 (better score)
      logger.i('\n--- ATTEMPT 2: 8/10 (better) ---');
      manager = ExamSessionManager();
      manager.start(testLevel);
      for (int i = 0; i < 8; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }
      for (int i = 0; i < 2; i++) {
        manager.nextStage(StageResult(isCorrect: false));
      }
      logger.i('Session finished with ${manager.correctCount}/10 correct');
      await manager.saveExamResult(testUserId, testLevel);

      progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
      expect(progress!.bestScore, equals(8));
      expect(progress.attempts, equals(2));
      expect(progress.completed, isFalse);
      logger.i('LevelProgress after attempt 2:');
      logger.i('  bestScore: ${progress.bestScore} (updated!), attempts: ${progress.attempts}, completed: ${progress.completed}');

      // third attempt: 5/10 (worse score, shouldn't update bestScore)
      logger.i('\n--- ATTEMPT 3: 5/10 (worse) ---');
      manager = ExamSessionManager();
      manager.start(testLevel);
      for (int i = 0; i < 5; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }
      for (int i = 0; i < 5; i++) {
        manager.nextStage(StageResult(isCorrect: false));
      }
      logger.i('Session finished with ${manager.correctCount}/10 correct');
      await manager.saveExamResult(testUserId, testLevel);

      progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
      expect(progress!.bestScore, equals(8)); // should still be 8, not 5
      expect(progress.attempts, equals(3));
      expect(progress.completed, isFalse);
      logger.i('LevelProgress after attempt 3:');
      logger.i('  bestScore: ${progress.bestScore} (NOT updated, kept 8), attempts: ${progress.attempts}, completed: ${progress.completed}');
      logger.i('═══════════════════════════════════════════════════');
    });

    test('should mark as completed only when achieving 100%', () async {
      logger.i('Testing completion only at 100%...');

      // first attempt: 9/10 (not completed)
      logger.i('\n--- ATTEMPT 1: 9/10 (not completed) ---');
      manager.start(testLevel);
      for (int i = 0; i < 9; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }
      manager.nextStage(StageResult(isCorrect: false));
      logger.i('Session finished with ${manager.correctCount}/10 correct');
      await manager.saveExamResult(testUserId, testLevel);

      var progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
      expect(progress!.bestScore, equals(9));
      expect(progress.completed, isFalse);
      expect(progress.firstCompletedAt, isNull);
      logger.i('LevelProgress after 9/10:');
      logger.i('  bestScore: ${progress.bestScore}');
      logger.i('  completed: ${progress.completed}');
      logger.i('  firstCompletedAt: ${progress.firstCompletedAt} (null because not completed)');
      logger.i('  attempts: ${progress.attempts}');

      // second attempt: 10/10 (completed!)
      logger.i('\n--- ATTEMPT 2: 10/10 (COMPLETED!) ---');
      manager = ExamSessionManager();
      manager.start(testLevel);
      for (int i = 0; i < 10; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }
      logger.i('Session finished with ${manager.correctCount}/10 correct');
      await manager.saveExamResult(testUserId, testLevel);

      progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
      expect(progress!.bestScore, equals(10));
      expect(progress.completed, isTrue);
      expect(progress.firstCompletedAt, isNotNull);
      expect(progress.attempts, equals(2));
      logger.i('LevelProgress after 10/10:');
      logger.i('  bestScore: ${progress.bestScore}');
      logger.i('  completed: ${progress.completed} ✓');
      logger.i('  firstCompletedAt: ${progress.firstCompletedAt} (NOW SET!)');
      logger.i('  attempts: ${progress.attempts}');
      logger.i('═══════════════════════════════════════════════════');
    });

    test('should increment attempts counter on each save', () async {
      logger.i('Testing attempts counter...');

      for (int attempt = 1; attempt <= 3; attempt++) {
        manager = ExamSessionManager();
        manager.start(testLevel);
        
        // always fail to keep it simple
        for (int i = 0; i < 10; i++) {
          manager.nextStage(StageResult(isCorrect: false));
        }
        
        await manager.saveExamResult(testUserId, testLevel);

        final progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
        expect(progress!.attempts, equals(attempt));
        logger.i('Attempt $attempt saved');
      }

      logger.i('Attempts counter test passed');
    });

    test('should save result with zero score', () async {
      logger.i('Testing zero score save (0/10)...');
      manager.start(testLevel);

      // complete all 10 stages incorrectly
      for (int i = 0; i < 10; i++) {
        manager.nextStage(StageResult(isCorrect: false));
      }

      expect(manager.isFinished, isTrue);
      expect(manager.correctCount, equals(0));
      logger.i('Session finished with ${manager.correctCount}/10 correct (worst case)');

      // save the result
      await manager.saveExamResult(testUserId, testLevel);
      logger.i('Result saved to LocalSaves');

      // Verify saved progress
      final progress = LocalSaves.getLevelProgress(testUserId, testLevel.levelId);
      expect(progress, isNotNull);
      expect(progress!.bestScore, equals(0));
      expect(progress.completed, isFalse);
      expect(progress.attempts, equals(1));
      expect(progress.firstCompletedAt, isNull);
      expect(progress.lastPlayedAt, isNotNull);

      logger.i('═══════════════════════════════════════════════════');
      logger.i('LevelProgress after zero score (0/10):');
      logger.i('  levelId: ${progress.levelId}');
      logger.i('  bestScore: ${progress.bestScore}/10');
      logger.i('  completed: ${progress.completed}');
      logger.i('  attempts: ${progress.attempts}');
      logger.i('  firstCompletedAt: ${progress.firstCompletedAt}');
      logger.i('  lastPlayedAt: ${progress.lastPlayedAt}');
      logger.i('  bestTimeSeconds: ${progress.bestTimeSeconds}');
      logger.i('═══════════════════════════════════════════════════');
    });
  });
}
