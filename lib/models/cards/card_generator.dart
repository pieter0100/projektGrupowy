import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

class CardGenerator {
  int pairsAmount;
  List<CardItem> cardsDeck = List.empty(growable: true);
  int typeOfMultiplication;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  CardGenerator({
    required this.pairsAmount,
    required this.typeOfMultiplication,
  }) {
    // create cards for the cardsDeck
    for (int i = 0; i < pairsAmount; i++) {
      // generate uuid's for card pair
      var uuid = Uuid();
      var idOne = uuid.v4();
      var idSecond = uuid.v4();

      // first card from pair
      CardItem cardOne = CardItem(
        id: idOne,
        pairId: idSecond,
        value: "$typeOfMultiplication×${i + 1}",
      );

      // second card from pair
      CardItem cardTwo = CardItem(
        id: idSecond,
        pairId: idOne,
        value: "${typeOfMultiplication * (i + 1)}",
      );

      // add cards to deck
      cardsDeck.add(cardOne);
      cardsDeck.add(cardTwo);
    }

    // shuffle deck at the end
    shuffleCardsDeck();
  }

  // shuffle cards
  void shuffleCardsDeck() {
    cardsDeck.shuffle();
  }

  // for debugging
  void printCardDeck() {
    _logger.i("Print all cards from deck: \n");
    for (var card in cardsDeck) {
      _logger.i(card.toString());
    }
  }
}
