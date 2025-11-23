import 'package:projekt_grupowy/models/card_item.dart';

class CardGenerator {
  int pairsAmount;
  List<CardItem> cardsDeck = List.empty(growable: true);
  int typeOfMultiplication;

  CardGenerator(this.pairsAmount, this.typeOfMultiplication) {
    // create cards for the cardsDeck
    for (int i = 0; i < pairsAmount; i++) {
      // card one
      CardItem cardOne = CardItem(
        i,
        i + 10,
        "$typeOfMultiplication x ${i + 1}",
        false,
      );

      // card one pair
      CardItem cardTwo = CardItem(
        i + 10,
        i,
        "${typeOfMultiplication * (i + 1)}",
        false,
      );

      // add cards to deck
      cardsDeck.add(cardOne);
      cardsDeck.add(cardTwo);
    }
  }

  void shuffleCardsDeck() {
    // shuffle cards
    cardsDeck.shuffle();
  }

  void printCardDeck() {
    // for debugging
    print("Print all cards from deck: \n");
    for (var card in cardsDeck) {
      print(card);
    }
  }
}
