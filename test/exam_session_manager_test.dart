import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/game_logic/round_managers/exam_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';
import 'package:logger/logger.dart';

void main() {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  group('ExamSessionManager', () {
    late ExamSessionManager manager;
    late LevelInfo testLevel;

    setUp(() {
      manager = ExamSessionManager();
      testLevel = LevelInfo(
        levelId: 'test-1',
        levelNumber: 1,
        name: 'Test Level',
        description: 'Test Description',
        unlockRequirements: UnlockRequirements(
          minPoints: 0,
          previousLevelId: null,
        ),
        rewards: Rewards(points: 10),
        isRevision: false,
      );
    });

    test('should generate exactly 10 stages', () {
      logger.i('Testing stage generation...');
      manager.start(testLevel);

      expect(manager.totalCount, equals(10));
      expect(manager.currentStage, equals(0));
      expect(manager.completedCount, equals(0));
      expect(manager.isFinished, isFalse);

      logger.i('Total stages: ${manager.totalCount}');
      logger.i('Stage generation test passed');
    });

    test('should always generate Typed stages only', () {
      logger.i('Testing that all stages are Typed (no randomization)...');
      
      for (int run = 0; run < 5; run++) {
        manager = ExamSessionManager();
        manager.start(testLevel);

        for (int i = 0; i < manager.totalCount; i++) {
          expect(manager.currentType, equals(StageType.typed));
          logger.i('Run ${run + 1}, Stage ${i + 1}: ${manager.currentType}');
          
          if (i < manager.totalCount - 1) {
            manager.nextStage(StageResult(isCorrect: true));
          }
        }
      }
      
      logger.i('No randomization test passed');
    });

    test('should never allow skipping stages', () {
      logger.i('Testing skip rules...');
      manager.start(testLevel);

      for (int i = 0; i < manager.totalCount; i++) {
        expect(manager.canSkipStage(), isFalse);
        
        if (i < manager.totalCount - 1) {
          manager.nextStage(StageResult(isCorrect: true));
        }
      }
      
      logger.i('Skip rules test passed');
    });

    test('should throw error when trying to skip any stage', () {
      logger.i('Testing skip exception...');
      manager.start(testLevel);

      expect(
        () => manager.skipCurrentStage(),
        throwsA(isA<UnsupportedError>()),
      );
      
      logger.i('Skip exception test passed');
    });

    test('should track correct answers accurately', () {
      logger.i('Testing accuracy tracking...');
      manager.start(testLevel);

      expect(manager.correctCount, equals(0));
      expect(manager.getAccuracy(), equals(0.0));

      manager.nextStage(StageResult(isCorrect: true));
      expect(manager.correctCount, equals(1));
      logger.i('After 1 correct: ${manager.correctCount}/10');

      manager.nextStage(StageResult(isCorrect: false));
      expect(manager.correctCount, equals(1));
      logger.i('After 1 incorrect: ${manager.correctCount}/10');

      manager.nextStage(StageResult(isCorrect: true));
      expect(manager.correctCount, equals(2));
      logger.i('After 2 correct: ${manager.correctCount}/10');
      
      logger.i('Accuracy tracking test passed');
    });

    test('should calculate accuracy correctly', () {
      logger.i('Testing accuracy calculation...');
      manager.start(testLevel);

      expect(manager.getAccuracy(), equals(0.0));

      for (int i = 0; i < 7; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }
      
      for (int i = 0; i < 3; i++) {
        manager.nextStage(StageResult(isCorrect: false));
      }

      expect(manager.correctCount, equals(7));
      expect(manager.getAccuracy(), equals(0.7));
      logger.i('Accuracy: ${manager.getAccuracy()} (7/10)');
      
      logger.i('Accuracy calculation test passed');
    });

    test('should finish after 10 completed stages', () {
      logger.i('Testing completion...');
      manager.start(testLevel);

      for (int i = 0; i < 9; i++) {
        expect(manager.isFinished, isFalse);
        manager.nextStage(StageResult(isCorrect: true));
        logger.i('Stage ${i + 1} completed');
      }

      expect(manager.completedCount, equals(9));
      expect(manager.isFinished, isFalse);

      manager.nextStage(StageResult(isCorrect: true));
      logger.i('Stage 10 completed');
      
      expect(manager.completedCount, equals(10));
      expect(manager.isFinished, isTrue);
      expect(manager.currentStage, isNull);
      
      logger.i('Completion test passed');
    });

    test('should finish with correct accuracy on mixed results', () {
      logger.i('Testing mixed results scenario...');
      manager.start(testLevel);

      final results = [
        true, false, true, true, false,
        true, false, true, true, true
      ];

      for (int i = 0; i < results.length; i++) {
        manager.nextStage(StageResult(isCorrect: results[i]));
        logger.i('Stage ${i + 1}: ${results[i] ? "correct" : "incorrect"}');
      }

      expect(manager.isFinished, isTrue);
      expect(manager.correctCount, equals(7));
      expect(manager.getAccuracy(), equals(0.7));
      
      logger.i('Mixed results test passed');
    });

    test('should throw error when calling nextStage after session is finished', () {
      manager.start(testLevel);

      for (int i = 0; i < 10; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.isFinished, isTrue);

      expect(
        () => manager.nextStage(StageResult(isCorrect: true)),
        throwsA(isA<StateError>()),
      );
    });

    test('should reset state when start() is called again', () {
      manager.start(testLevel);

      manager.nextStage(StageResult(isCorrect: true));
      manager.nextStage(StageResult(isCorrect: false));
      manager.nextStage(StageResult(isCorrect: true));

      expect(manager.completedCount, equals(3));
      expect(manager.correctCount, equals(2));
      expect(manager.currentStage, equals(3));

      manager.start(testLevel);

      expect(manager.completedCount, equals(0));
      expect(manager.correctCount, equals(0));
      expect(manager.currentStage, equals(0));
      expect(manager.isFinished, isFalse);
      expect(manager.totalCount, equals(10));
    });

    test('should notify listeners when state changes', () {
      var notificationCount = 0;
      manager.addListener(() {
        notificationCount++;
      });

      manager.start(testLevel);
      expect(notificationCount, equals(1));

      manager.nextStage(StageResult(isCorrect: true));
      expect(notificationCount, equals(2));

      manager.nextStage(StageResult(isCorrect: false));
      expect(notificationCount, equals(3));
    });

    test('should calculate progress correctly', () {
      manager.start(testLevel);

      expect(manager.getProgress(), equals(0.0));

      for (int i = 0; i < 5; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.getProgress(), equals(0.5));

      for (int i = 0; i < 5; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.getProgress(), equals(1.0));
    });

    test('should handle perfect score', () {
      logger.i('Testing perfect score...');
      manager.start(testLevel);

      for (int i = 0; i < 10; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.correctCount, equals(10));
      expect(manager.getAccuracy(), equals(1.0));
      expect(manager.isFinished, isTrue);
      
      logger.i('Perfect score: 10/10 (100%)');
      logger.i('Perfect score test passed');
    });

    test('should handle zero score', () {
      logger.i('Testing zero score...');
      manager.start(testLevel);

      for (int i = 0; i < 10; i++) {
        manager.nextStage(StageResult(isCorrect: false));
      }

      expect(manager.correctCount, equals(0));
      expect(manager.getAccuracy(), equals(0.0));
      expect(manager.isFinished, isTrue);
      
      logger.i('Zero score: 0/10 (0%)');
      logger.i('Zero score test passed');
    });
  });

  // NOTE: Integration tests for saveExamResult() in exam_session_manager_save_test.dart
  // Run with: flutter test test/exam_session_manager_save_test.dart
}
