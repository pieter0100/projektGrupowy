import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/services/typed_game_engine.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';

void main() {
  group('TypedGameEngine Tests', () {
    late TypedGameEngine engine;

    setUp(() {
      engine = TypedGameEngine();
      engine.initialize(2); // level 2 → type 2
    });

    test('Initialization sets up question correctly', () {
      expect(engine.question.prompt, contains('2'));
      expect(engine.question.correctAnswer, isNotEmpty);
    });

    test('Correct answer is marked as correct', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      final correctAnswer = engine.correctAnswer;
      engine.submitAnswer(correctAnswer);

      expect(capturedResult, isNotNull);
      expect(capturedResult!.isCorrect, true);
      expect(capturedResult!.skipped, false);
      expect(capturedResult!.userAnswer, correctAnswer);
    });

    test('Incorrect answer is marked as incorrect', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      engine.submitAnswer('wrong answer');

      expect(capturedResult, isNotNull);
      expect(capturedResult!.isCorrect, false);
      expect(capturedResult!.skipped, false);
    });

    test('Answer normalization: case insensitive', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      final correctAnswer = engine.correctAnswer;
      final uppercaseAnswer = correctAnswer.toUpperCase();
      engine.submitAnswer(uppercaseAnswer);

      expect(capturedResult!.isCorrect, true);
    });

    test('Answer normalization: whitespace trimmed', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      final correctAnswer = engine.correctAnswer;
      final paddedAnswer = '  $correctAnswer  ';
      engine.submitAnswer(paddedAnswer);

      expect(capturedResult!.isCorrect, true);
    });

    test('Combined normalization: case + whitespace', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      final correctAnswer = engine.correctAnswer;
      final complexAnswer = '  ${correctAnswer.toUpperCase()}  ';
      engine.submitAnswer(complexAnswer);

      expect(capturedResult!.isCorrect, true);
    });

    test('Skip generates skipped StageResult with correct answer', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      final correctAnswer = engine.correctAnswer;
      engine.skip();

      expect(capturedResult, isNotNull);
      expect(capturedResult!.skipped, true);
      expect(capturedResult!.isCorrect, false);
      expect(
        (capturedResult!.userAnswer as Map)['correctAnswer'],
        correctAnswer,
      );
    });

    test('Cannot skip after answer submitted', () {
      engine.initialize(2);
      engine.submitAnswer('some answer');

      expect(() => engine.skip(), throwsStateError);
    });

    test('Cannot submit after skip', () {
      engine.initialize(2);
      engine.skip();

      expect(() => engine.submitAnswer('answer'), throwsStateError);
    });

    test('Empty answer is marked as incorrect', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      engine.submitAnswer('');

      expect(capturedResult!.isCorrect, false);
    });

    test('Whitespace-only answer is marked as incorrect', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      engine.submitAnswer('   ');

      expect(capturedResult!.isCorrect, false);
    });

    test('getGameState returns correct map', () {
      engine.initialize(2);
      engine.submitAnswer('test answer');

      final state = engine.getGameState();

      expect(state['question'], isNotEmpty);
      expect(state['userAnswer'], 'test answer');
      expect(state['skipped'], false);
      expect(state['correctAnswer'], isNotEmpty);
    });

    test('Different levels have different multiplication types', () {
      engine.initialize(1);
      final answer1 = engine.correctAnswer;

      engine.initialize(5);
      final answer5 = engine.correctAnswer;

      // They should generally be different (not guaranteed but very likely)
      // This is a probabilistic test
      expect(
        (answer1 != answer5),
        true,
        reason: 'Answers for different levels should likely differ',
      );
    });

    test('Numeric answer comparison works', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2); // 2 × n = result

      // The correct answer should be numeric
      final correctAnswer = engine.correctAnswer;
      expect(int.tryParse(correctAnswer), isNotNull);

      engine.submitAnswer(correctAnswer);
      expect(capturedResult!.isCorrect, true);
    });

    test('Callback is called with correct stage result', () {
      StageResult? capturedResult;

      engine = TypedGameEngine(
        onComplete: (result) {
          capturedResult = result;
        },
      );
      engine.initialize(2);

      expect(capturedResult, isNull);

      engine.submitAnswer('test');

      expect(capturedResult, isNotNull);
      expect(capturedResult is StageResult, true);
    });

    test('onComplete not called if callback is null', () {
      engine = TypedGameEngine(onComplete: null);
      engine.initialize(2);

      // Should not throw
      expect(() => engine.submitAnswer('answer'), returnsNormally);
    });

    test('getGameState after skip reflects skipped state', () {
      engine.initialize(2);
      engine.skip();

      final state = engine.getGameState();

      expect(state['skipped'], true);
      expect(state['userAnswer'], isNull);
    });
  });
}
