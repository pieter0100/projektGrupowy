import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/game_logic/round_manager.dart';
import 'package:logger/logger.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';

void main() {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0
    ),
  );

  group('RoundManager Tests', () {
    late RoundManager roundManager;

    setUp(() {
      // Initialize before each test
      roundManager = RoundManager(
        pairsAmount: 5,
        typeOfMultiplication: 2,
      );
    });

    test('Initial state is correct', () {
      logger.i('Testing initial state...');
      roundManager.logGameState();
      
      expect(roundManager.matchedPairs, 0);
      expect(roundManager.attempts, 0);
      expect(roundManager.roundStatus, RoundStatus.ongoing);
      expect(roundManager.currentDeck.length, 10); // 5 pairs = 10 cards
      
      logger.i('Initial state test passed');
    });

    test('getProgress returns correct value', () {
      logger.i('Testing getProgress method...');
      
      expect(roundManager.getProgress(), 0.0);
      roundManager.logGameState();
      
      roundManager.matchedPairs = 2;
      expect(roundManager.getProgress(), 0.4);
      roundManager.logGameState();
      
      logger.i('getProgress test passed');
    });

    test('resetRound works correctly', () {
      logger.i('Testing resetRound method...');
      
      roundManager.matchedPairs = 3;
      roundManager.attempts = 5;
      logger.i('Before reset:');
      roundManager.logGameState();
      
      roundManager.resetRound();
      logger.i('After reset:');
      roundManager.logGameState();
      
      expect(roundManager.matchedPairs, 0);
      expect(roundManager.attempts, 0);
      expect(roundManager.roundStatus, RoundStatus.ongoing);
      
      logger.i('resetRound test passed');
    });

    test('onCardSelected works correctly', () {
      logger.i('Testing onCardSelected method...');

      logger.i('Selecting first card...');
      CardItem firstCard = roundManager.currentDeck[0];
      MatchStatus? status1 = roundManager.onCardSelected(firstCard);
      logger.i('After first selection:');
      roundManager.logGameState();
      expect(status1, isNull); // First selection returns null (waiting for second card)
      expect(roundManager.selectedCards.length, 1);

      logger.i('Selecting second card...');
      CardItem secondCard = roundManager.currentDeck[1];
      MatchStatus? status2 = roundManager.onCardSelected(secondCard);
      logger.i('After second selection:');
      roundManager.logGameState();
      expect(status2, isNotNull); // Second selection returns a status
      expect(roundManager.selectedCards.length, 0); // Cards are cleared after check
      
      logger.i('onCardSelected test passed');
    });

    test('Backend correctly recognizes matched pairs', () {
      logger.i('Testing matched pair recognition...');

      // Find a matching pair in the deck
      CardItem? firstCard;
      CardItem? secondCard;

      for (var card in roundManager.currentDeck) {
        if (firstCard == null) {
          firstCard = card;
        } else if (card.pairId == firstCard.id) {
          secondCard = card;
          break;
        }
      }

      expect(firstCard, isNotNull);
      expect(secondCard, isNotNull);

      logger.i('Selecting matching pair...');
      logger.i('First card: ${firstCard!.value}, ID: ${firstCard.id}');
      logger.i('Second card: ${secondCard!.value}, ID: ${secondCard.id}');

      MatchStatus? status1 = roundManager.onCardSelected(firstCard);
      expect(status1, isNull);

      MatchStatus? status2 = roundManager.onCardSelected(secondCard);
      expect(status2, MatchStatus.matchFound);
      expect(roundManager.matchedPairs, 1);
      expect(firstCard.isMatched, true);
      expect(secondCard.isMatched, true);

      roundManager.logGameState();
      logger.i('Matched pair recognition test passed');
    });

    test('Backend correctly recognizes non-matched pairs', () {
      logger.i('Testing non-matched pair recognition...');

      // Find two cards that don't match
      CardItem firstCard = roundManager.currentDeck[0];
      CardItem? secondCard;

      for (var card in roundManager.currentDeck) {
        if (card.id != firstCard.id && card.pairId != firstCard.id) {
          secondCard = card;
          break;
        }
      }

      expect(secondCard, isNotNull);

      logger.i('Selecting non-matching pair...');
      logger.i('First card: ${firstCard.value}, ID: ${firstCard.id}');
      logger.i('Second card: ${secondCard!.value}, ID: ${secondCard.id}');

      MatchStatus? status1 = roundManager.onCardSelected(firstCard);
      expect(status1, isNull);

      MatchStatus? status2 = roundManager.onCardSelected(secondCard);
      expect(status2, MatchStatus.matchFailed);
      expect(roundManager.matchedPairs, 0);
      expect(firstCard.isMatched, false);
      expect(secondCard.isMatched, false);

      roundManager.logGameState();
      logger.i('Non-matched pair recognition test passed');
    });

    test('Matched cards cannot be clicked again', () {
      logger.i('Testing that matched cards cannot be selected again...');

      // Find and match a pair
      CardItem? firstCard;
      CardItem? secondCard;

      for (var card in roundManager.currentDeck) {
        if (firstCard == null) {
          firstCard = card;
        } else if (card.pairId == firstCard.id) {
          secondCard = card;
          break;
        }
      }

      // Match the pair
      roundManager.onCardSelected(firstCard!);
      MatchStatus? matchStatus = roundManager.onCardSelected(secondCard!);
      expect(matchStatus, MatchStatus.matchFound);
      expect(firstCard.isMatched, true);

      logger.i('Pair matched. Attempting to select matched card again...');

      // Try to select the matched card again
      MatchStatus? status = roundManager.onCardSelected(firstCard);
      expect(status, MatchStatus.cannotSelect);
      expect(roundManager.selectedCards.length, 0);

      roundManager.logGameState();
      logger.i('Matched cards blocking test passed');
    });

    test('Complete round without UI - all pairs matched', () {
      logger.i('Testing complete round simulation...');

      int totalPairs = roundManager.pairsAmount;
      int matchedCount = 0;

      while (roundManager.roundStatus == RoundStatus.ongoing) {
        // Find next unmatched pair
        CardItem? firstCard;
        CardItem? secondCard;

        for (var card in roundManager.currentDeck) {
          if (!card.isMatched) {
            if (firstCard == null) {
              firstCard = card;
            } else if (card.pairId == firstCard.id) {
              secondCard = card;
              break;
            }
          }
        }

        if (firstCard != null && secondCard != null) {
          logger.i('Matching pair ${matchedCount + 1}/$totalPairs');
          roundManager.onCardSelected(firstCard);
          MatchStatus? status = roundManager.onCardSelected(secondCard);
          
          expect(status, MatchStatus.matchFound);
          matchedCount++;
          if (matchedCount == totalPairs) {
            expect(roundManager.roundStatus, RoundStatus.roundCompleted);
            logger.i('Round completed!');
          }
        }

        roundManager.logGameState();
      }

      expect(roundManager.matchedPairs, totalPairs);
      expect(roundManager.roundStatus, RoundStatus.roundCompleted);
      expect(roundManager.getProgress(), 1.0);

      logger.i('Complete round test passed');
    });
  });
}