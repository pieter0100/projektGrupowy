import 'package:projekt_grupowy/services/card_generator.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:logger/logger.dart';
import 'package:projekt_grupowy/services/question_provider.dart';

enum MatchStatus {
  matchFound,
  matchFailed,
  cannotSelect, // e.g., same card selected, already matched card selected, selecting more than 2 cards
}

enum RoundStatus { ongoing, roundCompleted }

class RoundManager {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  CardGenerator cardGenerator;
  int pairsAmount;
  int typeOfMultiplication;
  List<CardItem> currentDeck;

  int matchedPairs = 0;
  List<CardItem> matchedPairsList = List.empty(growable: true);

  int attempts = 0;
  RoundStatus roundStatus = RoundStatus.ongoing;

  List<CardItem> selectedCards = [];

  RoundManager({required this.pairsAmount, required this.typeOfMultiplication})
      : cardGenerator = CardGenerator(
          questions: QuestionProvider.getPairsQuestions(
            level: typeOfMultiplication,
            pairsAmount: pairsAmount,
          ),
        ),
        currentDeck = [] {
    currentDeck = cardGenerator.cardsDeck;
  }

  MatchStatus? onCardSelected(CardItem card) {
    if (isCardAlreadyMatched(card)) {
      return MatchStatus.cannotSelect;
    }

    if (selectedCards.length < 2) {
      selectedCards.add(card);
    } else {
      return MatchStatus.cannotSelect;
    }

    if (selectedCards.length == 2) {
      return checkSelectedCards();
    }

    return null; // waiting for the second card to be selected
  }

  MatchStatus checkSelectedCards() {
    if (are2CardsSelected() == false) {
      return MatchStatus.cannotSelect;
    }

    attempts += 1;

    CardItem firstCard = selectedCards[0];
    CardItem secondCard = selectedCards[1];

    if (areSameCardsSelected(firstCard, secondCard)) {
      selectedCards.clear();
      return MatchStatus.cannotSelect;
    }

    if (isCardAlreadyMatched(firstCard) || isCardAlreadyMatched(secondCard)) {
      selectedCards.clear();
      return MatchStatus.cannotSelect;
    }

    // check for a match
    if (firstCard.pairId == secondCard.id) {
      // mark cards as matched
      firstCard.isMatched = true;
      secondCard.isMatched = true;

      matchedPairs += 1;
      matchedPairsList.addAll([firstCard, secondCard]);

      // clear selected cards
      selectedCards.clear();

      // check if round is completed
      if (getProgress() >= 1.0) {
        roundStatus = RoundStatus.roundCompleted;
      }

      return MatchStatus.matchFound;
    } else {
      firstCard.isFailed = true;
      secondCard.isFailed = true;
      return MatchStatus.matchFailed;
    }
  }

  bool areSameCardsSelected(CardItem firstCard, CardItem secondCard) {
    return firstCard.id == secondCard.id;
  }

  bool isCardAlreadyMatched(CardItem card) {
    return card.isMatched;
  }

  bool are2CardsSelected() {
    return selectedCards.length == 2;
  }

  bool isRoundCompleted() {
    return roundStatus == RoundStatus.roundCompleted;
  }

  // returns % of progress
  double getProgress() {
    return matchedPairs / pairsAmount;
  }

  // resets the round to initial state, keeping the same settings but with a new shuffled deck
  void resetRound() {
    matchedPairs = 0;
    matchedPairsList.clear();
    attempts = 0;
    roundStatus = RoundStatus.ongoing;
    selectedCards.clear();
    currentDeck = cardGenerator.cardsDeck;
  }

  // returns the current game state as a map
  Map<String, dynamic> getGameState() {
    return {
      'matchedPairs': matchedPairs,
      'totalPairs': pairsAmount,
      'attempts': attempts,
      'progress': getProgress(),
      'status': roundStatus,
      'selectedCardsCount': selectedCards.length,
    };
  }

  void logGameState() {
    Map<String, dynamic> state = getGameState();
    _logger.i('''
    Game State:
    Matched Pairs: ${state['matchedPairs']}
    Total Pairs: ${state['totalPairs']}
    Attempts: ${state['attempts']}
    Progress: ${(state['progress'] * 100).toStringAsFixed(2)}%
    Round Status: ${state['status']}
    Selected Cards Count: ${state['selectedCardsCount']}
    ''');
  }

  void logMessage(String message) {
    _logger.i(message);
  }
}
