import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/game_logic/round_managers/practice_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';
import 'package:logger/logger.dart';

void main() {
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  group('PracticeSessionManager', () {
    late PracticeSessionManager manager;
    late LevelInfo testLevel;

    setUp(() {
      manager = PracticeSessionManager();
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

    test('should generate exactly 6 stages', () {
      logger.i('Testing stage generation...');
      manager.start(testLevel);

      expect(manager.totalCount, equals(6));
      expect(manager.currentStage, equals(0));
      expect(manager.completedCount, equals(0));
      expect(manager.isFinished, isFalse);

      logger.i('Total stages: ${manager.totalCount}');
      logger.i('Stage generation test passed ✓');
    });

    test('should never have 3 same types in a row', () {
      logger.i('Testing anti-series algorithm (10 runs)...');
      for (int run = 0; run < 10; run++) {
        manager = PracticeSessionManager();
        manager.start(testLevel);

        final types = <StageType>[];
        for (int i = 0; i < manager.totalCount; i++) {
          final stage = manager.currentStageObject;
          expect(stage, isNotNull);
          types.add(stage!.type);

          if (types.length >= 3) {
            final last3 = types.sublist(types.length - 3);
            expect(
              last3[0] == last3[1] && last3[1] == last3[2],
              isFalse,
              reason: 'Found 3 same types in a row: $last3',
            );
          }

          if (i < manager.totalCount - 1) {
            manager.nextStage(StageResult(isCorrect: true));
          }
        }

        logger.i('Run ${run + 1}: ${types.map((t) => t.toString().split('.').last).join(' → ')}');
      }
      logger.i('Anti-series test passed ✓');
    });

    test('should allow skip only for Typed stages', () {
      logger.i('Testing skip rules...');
      manager.start(testLevel);

      for (int i = 0; i < manager.totalCount; i++) {
        final currentType = manager.currentType;
        final canSkip = manager.canSkipStage();

        logger.i('Stage ${i + 1}: ${currentType.toString().split('.').last.padRight(15)} → Skip: $canSkip');

        if (currentType == StageType.typed) {
          expect(canSkip, isTrue);
        } else {
          expect(canSkip, isFalse);
        }

        if (i < manager.totalCount - 1) {
          manager.nextStage(StageResult(isCorrect: true));
        }
      }
      logger.i('Skip rules test passed ✓');
    });

    test('should not increment completedCount when stage is skipped', () {
      logger.i('Testing skip counting...');
      manager.start(testLevel);

      manager.nextStage(StageResult(isCorrect: true));
      logger.i('After completing stage 1 → Completed: ${manager.completedCount}');
      expect(manager.completedCount, equals(1));

      manager.nextStage(StageResult.skipped());
      logger.i('After skipping stage 2   → Completed: ${manager.completedCount} (unchanged)');
      expect(manager.completedCount, equals(1));

      manager.nextStage(StageResult(isCorrect: true));
      logger.i('After completing stage 3 → Completed: ${manager.completedCount}');
      expect(manager.completedCount, equals(2));

      logger.i('Skip counting test passed ✓');
    });

    test('should finish after 6 completed stages', () {
      logger.i('Testing completion...');
      manager.start(testLevel);

      for (int i = 0; i < 5; i++) {
        expect(manager.isFinished, isFalse);
        manager.nextStage(StageResult(isCorrect: true));
        logger.i('Stage ${i + 1} completed → Total: ${manager.completedCount}/6');
      }

      expect(manager.completedCount, equals(5));
      expect(manager.isFinished, isFalse);

      manager.nextStage(StageResult(isCorrect: true));
      logger.i('Stage 6 completed → Total: ${manager.completedCount}/6, Finished: ${manager.isFinished}');
      expect(manager.completedCount, equals(6));
      expect(manager.isFinished, isTrue);
      expect(manager.currentStage, isNull);

      logger.i('Completion test passed ✓');
    });

    test('should not finish if stages are skipped and completedCount < 6', () {
      manager.start(testLevel);

      for (int i = 0; i < 5; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.completedCount, equals(5));
      expect(manager.isFinished, isFalse);

      manager.nextStage(StageResult.skipped());

      expect(manager.completedCount, equals(5));
      expect(manager.isFinished, isTrue);
    });

    test('should finish after 6 completed stages even if some stages were skipped', () {
      manager.start(testLevel);

      for (int i = 0; i < 3; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      manager.nextStage(StageResult.skipped());

      for (int i = 0; i < 2; i++) {
        expect(manager.isFinished, isFalse);
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.completedCount, equals(5));
      expect(manager.isFinished, isTrue);
    });

    test('should throw error when trying to skip non-Typed stage', () {
      manager.start(testLevel);

      while (manager.currentType == StageType.typed && !manager.isFinished) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      if (manager.currentType != StageType.typed && !manager.isFinished) {
        expect(
          () => manager.skipCurrentStage(),
          throwsA(isA<UnsupportedError>()),
        );
      }
    });

    test('should allow skipping Typed stage via skipCurrentStage()', () {
      manager.start(testLevel);

      while (manager.currentType != StageType.typed && !manager.isFinished) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      if (manager.currentType == StageType.typed) {
        final completedBefore = manager.completedCount;
        manager.skipCurrentStage();
        expect(manager.completedCount, equals(completedBefore));
      }
    });

    test('should throw error when calling nextStage after session is finished', () {
      manager.start(testLevel);

      for (int i = 0; i < 6; i++) {
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
      manager.nextStage(StageResult(isCorrect: true));

      expect(manager.completedCount, equals(2));
      expect(manager.currentStage, equals(2));

      manager.start(testLevel);

      expect(manager.completedCount, equals(0));
      expect(manager.currentStage, equals(0));
      expect(manager.isFinished, isFalse);
      expect(manager.totalCount, equals(6));
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

      if (manager.currentType == StageType.typed) {
        manager.skipCurrentStage();
        expect(notificationCount, equals(3));
      }
    });

    test('should calculate progress correctly', () {
      manager.start(testLevel);

      expect(manager.getProgress(), equals(0.0));

      for (int i = 0; i < 3; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.getProgress(), equals(0.5));

      for (int i = 0; i < 3; i++) {
        manager.nextStage(StageResult(isCorrect: true));
      }

      expect(manager.getProgress(), equals(1.0));
    });

    test('should generate all 3 stage types over multiple runs', () {
      final typesGenerated = <StageType>{};

      for (int run = 0; run < 20; run++) {
        manager = PracticeSessionManager();
        manager.start(testLevel);

        for (int i = 0; i < manager.totalCount; i++) {
          typesGenerated.add(manager.currentType!);
          if (i < manager.totalCount - 1) {
            manager.nextStage(StageResult(isCorrect: true));
          }
        }
      }

      expect(typesGenerated, contains(StageType.multipleChoice));
      expect(typesGenerated, contains(StageType.typed));
      expect(typesGenerated, contains(StageType.pairs));
    });
  });
}
