import 'package:projekt_grupowy/services/card_generator.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:logger/logger.dart';
import 'package:projekt_grupowy/services/question_provider.dart';

enum SelectionStatus { matchFound, matchFailed, cannotSelect }

class PairsGameEngine {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  CardGenerator cardGenerator;
  final int pairsAmount;
  final int typeOfMultiplication;
  late List<CardItem> currentDeck;
  int matchedPairs = 0;
  List<CardItem> matchedPairsList = List.empty(growable: true);  int attempts = 0;
  List<CardItem> selectedCards = [];

  /// Callback fired when the game is completed (all pairs matched)
  final Function(StageResult)? onComplete;

  /// Status of individual card selections

  PairsGameEngine({
    required this.pairsAmount,
    required this.typeOfMultiplication,
    this.onComplete,
  }) : cardGenerator = CardGenerator(
         questions: QuestionProvider.getPairsQuestions(
           level: typeOfMultiplication,
           pairsAmount: pairsAmount,
         ),
       ),
       currentDeck = [] {
    currentDeck = cardGenerator.cardsDeck;
  }  SelectionStatus? onCardSelected(CardItem card) {
    if (isCardAlreadyMatched(card)) {
      return SelectionStatus.cannotSelect;
    }

    if (selectedCards.length < 2) {
      selectedCards.add(card);
    } else {
      return SelectionStatus.cannotSelect;
    }

    if (selectedCards.length == 2) {
      return checkSelectedCards();
    }

    return null; // waiting for the second card to be selected
  }
  SelectionStatus checkSelectedCards() {
    if (are2CardsSelected() == false) {
      return SelectionStatus.cannotSelect;
    }

    attempts += 1;

    CardItem firstCard = selectedCards[0];
    CardItem secondCard = selectedCards[1];
    
    if (areSameCardsSelected(firstCard, secondCard)) {
      selectedCards.clear();
      return SelectionStatus.cannotSelect;
    }

    if (isCardAlreadyMatched(firstCard) || isCardAlreadyMatched(secondCard)) {
      selectedCards.clear();
      return SelectionStatus.cannotSelect;
    }

    // check for a match
    if (firstCard.pairId == secondCard.id) {
      firstCard.isMatched = true;
      secondCard.isMatched = true;

      matchedPairs += 1;
      matchedPairsList.addAll([firstCard, secondCard]);

      // check if game is completed
      if (getProgress() >= 1.0) {
        _completeGame();
      }

      selectedCards.clear();
      return SelectionStatus.matchFound;
    } else {
      firstCard.isFailed = true;
      secondCard.isFailed = true;
      selectedCards.clear();
      return SelectionStatus.matchFailed;
    }
  }

  void _completeGame() {
    final result = StageResult(
      isCorrect: true,
      skipped: false,
      answerTime: null,
      userAnswer: {'matchedPairs': matchedPairs, 'attempts': attempts},
    );
    onComplete?.call(result);
  }

  /// Checks if two cards are the same (by ID)
  bool areSameCardsSelected(CardItem firstCard, CardItem secondCard) {
    return firstCard.id == secondCard.id;
  }

  /// Checks if a card has already been matched
  bool isCardAlreadyMatched(CardItem card) {
    return card.isMatched;
  }

  /// Checks if exactly 2 cards are selected
  bool are2CardsSelected() {
    return selectedCards.length == 2;
  }

  /// Checks if the game is completed (all pairs matched)
  bool isGameCompleted() {
    return getProgress() >= 1.0;
  }

  /// Returns progress as a decimal (0.0 - 1.0)
  double getProgress() {
    return matchedPairs / pairsAmount;
  }
  /// Resets the game to initial state with a new shuffled deck
  void resetGame() {
    matchedPairs = 0;
    matchedPairsList.clear();
    attempts = 0;
    selectedCards.clear();
    
    // Resetuj flagi w kartach
    for (var card in currentDeck) {
      card.isMatched = false;
      card.isFailed = false;
    }
    
    currentDeck.shuffle();
  }

  /// Returns the current game state as a map
  Map<String, dynamic> getGameState() {
    return {
      'matchedPairs': matchedPairs,
      'totalPairs': pairsAmount,
      'attempts': attempts,
      'progress': getProgress(),
      'selectedCardsCount': selectedCards.length,
      'isCompleted': isGameCompleted(),
    };
  }

  /// Logs the current game state
  void logGameState() {
    Map<String, dynamic> state = getGameState();
    _logger.i('''
    Pairs Game State:
    Matched Pairs: ${state['matchedPairs']}/${state['totalPairs']}
    Attempts: ${state['attempts']}
    Progress: ${(state['progress'] * 100).toStringAsFixed(2)}%
    Selected Cards: ${state['selectedCardsCount']}
    Completed: ${state['isCompleted']}
    ''');
  }

  /// Logs a custom message
  void logMessage(String message) {
    _logger.i(message);
  }
}
