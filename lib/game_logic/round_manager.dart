import 'package:projekt_grupowy/models/card_generator.dart';
import 'package:projekt_grupowy/models/card_item.dart';

enum MatchStatus {
  matchFound,
  matchFailed,
}

enum RoundStatus {
  ongoing,
  roundCompleted,
}

class RoundManager {

  CardGenerator cardGenerator;
  int pairsAmount;
  int typeOfMultiplication;
  List<CardItem> currentDeck;

  int matchedPairs = 0;
  List<CardItem> matchedPairsList = List.empty(growable: true);

  int attempts = 0;
  RoundStatus roundStatus = RoundStatus.ongoing;

  RoundManager({
    required this.pairsAmount,
    required this.typeOfMultiplication,
  }) : cardGenerator = CardGenerator(
          pairsAmount: pairsAmount,
          typeOfMultiplication: typeOfMultiplication,
        ),
        currentDeck = [] {
    currentDeck = cardGenerator.cardsDeck;
  }
  
}