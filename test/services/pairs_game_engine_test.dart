import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/services/pairs_game_engine.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';

// Import SelectionStatus enum from pairs_game_engine.dart

void main() {
  group('PairsGameEngine Tests', () {
    late PairsGameEngine engine;

    setUp(() {
      engine = PairsGameEngine(pairsAmount: 3, typeOfMultiplication: 2);
    });

    test('Initial state is correct', () {
      expect(engine.matchedPairs, 0);
      expect(engine.attempts, 0);
      expect(engine.selectedCards.length, 0);
      expect(engine.currentDeck.length, 6); // 3 pairs = 6 cards
      expect(engine.getProgress(), 0.0);
      expect(engine.isGameCompleted(), false);
    });

    test('Selecting first card returns null', () {
      final card = engine.currentDeck[0];
      final status = engine.onCardSelected(card);
      expect(status, isNull);
      expect(engine.selectedCards.length, 1);
    });
    test('Selecting same card twice returns cannotSelect', () {
      final card = engine.currentDeck[0];
      engine.onCardSelected(card);
      final status = engine.onCardSelected(card);
      expect(status, SelectionStatus.cannotSelect);
      expect(engine.selectedCards.length, 0); // should be cleared
    });
    test('Selecting two different unmatched cards triggers check', () {
      final card1 = engine.currentDeck[0];
      final card2 = engine.currentDeck[1];

      engine.onCardSelected(card1);
      final status = engine.onCardSelected(card2);

      // Status will be either matchFound or matchFailed depending on if they match
      expect(
        status,
        isIn([SelectionStatus.matchFound, SelectionStatus.matchFailed]),
      );
      expect(engine.selectedCards.length, 0); // cleared after check
    });

    test('Matching two correct cards increments matchedPairs', () {
      // Find a matching pair
      final card1 = engine.currentDeck[0];
      final card2Candidate = engine.currentDeck.firstWhere(
        (c) => c.pairId == card1.id && c.id != card1.id,
      );

      engine.onCardSelected(card1);
      final status = engine.onCardSelected(card2Candidate);

      expect(status, SelectionStatus.matchFound);
      expect(engine.matchedPairs, 1);
      expect(card1.isMatched, true);
      expect(card2Candidate.isMatched, true);
    });
    test('Unmatched cards get marked as failed', () {
      // Find two cards that don't match
      final card1 = engine.currentDeck[0];
      final card2 = engine.currentDeck.firstWhere(
        (c) => c.pairId != card1.id && c.id != card1.id,
      );

      engine.onCardSelected(card1);
      final status = engine.onCardSelected(card2);

      expect(status, SelectionStatus.matchFailed);
      expect(card1.isFailed, true);
      expect(card2.isFailed, true);
      expect(engine.matchedPairs, 0); // no match
    });
    test('Selecting already matched card returns cannotSelect', () {
      // Match a pair first
      final card1 = engine.currentDeck[0];
      final card2Candidate = engine.currentDeck.firstWhere(
        (c) => c.pairId == card1.id && c.id != card1.id,
      );

      engine.onCardSelected(card1);
      engine.onCardSelected(card2Candidate);

      // Try to select matched card again
      final status = engine.onCardSelected(card1);
      expect(status, SelectionStatus.cannotSelect);
    });

    test('Attempts counter increments after each pair check', () {
      final card1 = engine.currentDeck[0];
      final card2 = engine.currentDeck[1];

      expect(engine.attempts, 0);

      engine.onCardSelected(card1);
      engine.onCardSelected(card2); // first attempt

      expect(engine.attempts, 1);

      engine.onCardSelected(engine.currentDeck[2]);
      engine.onCardSelected(engine.currentDeck[3]); // second attempt

      expect(engine.attempts, 2);
    });

    test('Progress increases after matching pairs', () {
      expect(engine.getProgress(), 0.0);

      // Match first pair
      final card1 = engine.currentDeck[0];
      final card2Candidate = engine.currentDeck.firstWhere(
        (c) => c.pairId == card1.id && c.id != card1.id,
      );

      engine.onCardSelected(card1);
      engine.onCardSelected(card2Candidate);

      expect(engine.getProgress(), closeTo(1.0 / 3.0, 0.01));
    });

    test('isGameCompleted returns true when all pairs matched', () {
      // Match all pairs
      for (int i = 0; i < engine.pairsAmount; i++) {
        final unmatched = engine.currentDeck.firstWhere((c) => !c.isMatched);
        final partner = engine.currentDeck.firstWhere(
          (c) => c.pairId == unmatched.id && !c.isMatched,
        );

        engine.onCardSelected(unmatched);
        engine.onCardSelected(partner);
      }

      expect(engine.isGameCompleted(), true);
      expect(engine.matchedPairs, engine.pairsAmount);
    });

    test('onComplete callback is called when game finishes', () {
      StageResult? capturedResult;

      engine = PairsGameEngine(
        pairsAmount: 3,
        typeOfMultiplication: 2,
        onComplete: (result) {
          capturedResult = result;
        },
      );

      // Match all pairs
      for (int i = 0; i < engine.pairsAmount; i++) {
        final unmatched = engine.currentDeck.firstWhere((c) => !c.isMatched);
        final partner = engine.currentDeck.firstWhere(
          (c) => c.pairId == unmatched.id && !c.isMatched,
        );

        engine.onCardSelected(unmatched);
        engine.onCardSelected(partner);
      }

      expect(capturedResult, isNotNull);
      expect(capturedResult!.isCorrect, true);
      expect(capturedResult!.skipped, false);
      expect((capturedResult!.userAnswer as Map)['matchedPairs'], 3);
    });

    test('resetGame clears all state', () {
      // Play some game
      final card1 = engine.currentDeck[0];
      engine.onCardSelected(card1);

      engine.resetGame();

      expect(engine.matchedPairs, 0);
      expect(engine.attempts, 0);
      expect(engine.selectedCards.length, 0);
      expect(engine.getProgress(), 0.0);
    });

    test('getGameState returns correct map', () {
      final state = engine.getGameState();

      expect(state['matchedPairs'], 0);
      expect(state['totalPairs'], 3);
      expect(state['attempts'], 0);
      expect(state['progress'], 0.0);
      expect(state['selectedCardsCount'], 0);
      expect(state['isCompleted'], false);
    });

    test('Failed cards are marked with isFailed flag', () {
      // Find two cards that don't match
      final card1 = engine.currentDeck[0];
      final card2 = engine.currentDeck.firstWhere(
        (c) => c.pairId != card1.id && c.id != card1.id,
      );

      engine.onCardSelected(card1);
      engine.onCardSelected(card2);

      expect(card1.isFailed, true);
      expect(card2.isFailed, true);
    });
  });
}
