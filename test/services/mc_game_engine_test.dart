import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/services/mc_game_engine.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';

void main() {
  group('MCGameEngine Tests', () {
    late MCGameEngine engine;

    setUp(() {
      engine = MCGameEngine();
      engine.initialize(2); // level 2
    });

    test('Initialization sets up question correctly', () {
      expect(engine.question.prompt, isNotEmpty);
      expect(engine.question.options.length, 4);
      expect(engine.correctIndex, inInclusiveRange(0, 3));
    });

    test('Correct option selection is marked as correct', () {
      StageResult? capturedResult;

      engine = MCGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      final correctIndex = engine.correctIndex;
      engine.selectOption(correctIndex);

      expect(capturedResult, isNotNull);
      expect(capturedResult!.isCorrect, true);
      expect(capturedResult!.skipped, false);
      expect(
        (capturedResult!.userAnswer as Map)['selectedIndex'],
        correctIndex,
      );
    });

    test('Incorrect option selection is marked as incorrect', () {
      StageResult? capturedResult;

      engine = MCGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      final correctIndex = engine.correctIndex;
      final wrongIndex = (correctIndex + 1) % 4; // Pick different index

      engine.selectOption(wrongIndex);

      expect(capturedResult, isNotNull);
      expect(capturedResult!.isCorrect, false);
      expect(capturedResult!.skipped, false);
      expect((capturedResult!.userAnswer as Map)['selectedIndex'], wrongIndex);
    });

    test('Selected answer is stored correctly', () {
      engine.initialize(2);
      final selectedIndex = 0;
      engine.selectOption(selectedIndex);

      expect(engine.selectedAnswer, engine.question.options[selectedIndex]);
    });

    test('answerSelected flag is false before selection', () {
      engine.initialize(2);
      expect(engine.answerSelected, false);
    });

    test('answerSelected flag is true after selection', () {
      engine.initialize(2);
      engine.selectOption(0);

      expect(engine.answerSelected, true);
    });

    test('Cannot select answer twice', () {
      engine.initialize(2);
      engine.selectOption(0);

      expect(() => engine.selectOption(1), throwsStateError);
    });

    test('Invalid option index throws RangeError', () {
      engine.initialize(2);

      expect(() => engine.selectOption(-1), throwsRangeError);

      expect(() => engine.selectOption(4), throwsRangeError);
    });

    test('All options are different from each other', () {
      engine.initialize(2);

      final options = engine.question.options;
      final uniqueOptions = options.toSet();

      expect(
        uniqueOptions.length,
        options.length,
        reason: 'All options should be unique',
      );
    });

    test('Correct answer is in the options list', () {
      engine.initialize(2);

      final correctAnswer = engine.correctAnswer;
      final options = engine.question.options;

      expect(options.contains(correctAnswer), true);
    });

    test('getGameState returns correct map', () {
      engine.initialize(2);
      engine.selectOption(1);

      final state = engine.getGameState();

      expect(state['prompt'], isNotEmpty);
      expect(state['options'], isA<List>());
      expect(state['options'].length, 4);
      expect(state['correctIndex'], inInclusiveRange(0, 3));
      expect(state['selectedIndex'], 1);
      expect(state['answerSelected'], true);
    });

    test('Different levels have different questions', () {
      engine.initialize(1);
      final prompt1 = engine.question.prompt;

      engine.initialize(5);
      final prompt5 = engine.question.prompt;

      // They should be different (probabilistic test)
      expect(
        (prompt1 != prompt5),
        true,
        reason: 'Different levels should have different prompts',
      );
    });

    test('Callback is called with correct StageResult', () {
      StageResult? capturedResult;

      engine = MCGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      expect(capturedResult, isNull);

      engine.selectOption(0);

      expect(capturedResult, isNotNull);
      expect(capturedResult is StageResult, true);
    });

    test('onComplete not called if callback is null', () {
      engine = MCGameEngine(onComplete: null);
      engine.initialize(2);

      // Should not throw
      expect(() => engine.selectOption(0), returnsNormally);
    });

    test('StageResult includes selected answer in userAnswer', () {
      StageResult? capturedResult;

      engine = MCGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      engine.selectOption(0);

      final userAnswer = capturedResult!.userAnswer as Map;
      expect(userAnswer['selectedIndex'], 0);
      expect(userAnswer['selectedAnswer'], engine.question.options[0]);
    });

    test('Question prompt contains multiplication sign', () {
      engine.initialize(2);

      expect(
        engine.question.prompt,
        contains('×'),
        reason: 'Question should contain multiplication sign',
      );
    });

    test('All options are valid number strings', () {
      engine.initialize(2);

      for (final option in engine.question.options) {
        expect(
          int.tryParse(option),
          isNotNull,
          reason: 'All options should be parseable as integers',
        );
      }
    });

    test('Correct answer index matches correct option', () {
      engine.initialize(2);

      final correctIndex = engine.correctIndex;
      final correctAnswer = engine.correctAnswer;

      expect(engine.question.options[correctIndex], correctAnswer);
    });
  });
}
