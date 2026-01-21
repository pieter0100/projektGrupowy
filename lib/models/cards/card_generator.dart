import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'dart:math';

class CardGenerator {
  int pairsAmount;
  List<CardItem> cardsDeck = List.empty(growable: true);
  int typeOfMultiplication;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  CardGenerator({
    required this.pairsAmount,
    required this.typeOfMultiplication,
  }) {

    var uuid = Uuid();
    final usedMultipliers = <int>{};
    final rand = Random();
    while (usedMultipliers.length < pairsAmount) {
      int multiplier;
      do {
        multiplier = rand.nextInt(10) + 1; // random number from 1 to 10
      } while (usedMultipliers.contains(multiplier));
      usedMultipliers.add(multiplier);
      var idOne = uuid.v4();
      var idSecond = uuid.v4();
      // first card from pair
      CardItem cardOne = CardItem(
        id: idOne,
        pairId: idSecond,
        value: "$typeOfMultiplication×$multiplier",
      );
      // second card from pair
      CardItem cardTwo = CardItem(
        id: idSecond,
        pairId: idOne,
        value: "${typeOfMultiplication * multiplier}",
      );

      cardsDeck.add(cardOne);
      cardsDeck.add(cardTwo);
    }

    shuffleCardsDeck();
  }

  void shuffleCardsDeck() {
    cardsDeck.shuffle();
  }

  void printCardDeck() {
    _logger.i("Print all cards from deck: \n");
    for (var card in cardsDeck) {
      _logger.i(card.toString());
    }
  }
}
