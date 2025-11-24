import 'package:projekt_grupowy/models/card_item.dart';
import 'package:uuid/uuid.dart';

class CardGenerator {
  int pairsAmount;
  List<CardItem> cardsDeck = List.empty(growable: true);
  int typeOfMultiplication;

  CardGenerator(this.pairsAmount, this.typeOfMultiplication) {
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
        value: "$typeOfMultiplication x ${i + 1}",
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
  }

  // shuffle cards
  void shuffleCardsDeck() {
    cardsDeck.shuffle();
  }

  // for debugging
  void printCardDeck() {
    print("Print all cards from deck: \n");
    for (var card in cardsDeck) {
      print(card);
    }
  }
}
