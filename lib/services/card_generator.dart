import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';
import 'package:projekt_grupowy/services/question_provider.dart';

class CardGenerator {
  final QuestionsPairs questions;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  late final List<CardItem> cardsDeck;

  CardGenerator({required this.questions}) {
    cardsDeck = _generateDeckFromQuestions(questions);
    shuffleCardsDeck();
  }

  List<CardItem> _generateDeckFromQuestions(QuestionsPairs qp) {
    final uuid = Uuid();
    final deck = <CardItem>[];
    for (final m in qp.multipliers) {
      final idOne = uuid.v4();
      final idSecond = uuid.v4();
      final left = '${qp.typeOfMultiplication}×$m';
      final right = '${qp.typeOfMultiplication * m}';
      deck.add(CardItem(id: idOne, pairId: idSecond, value: left));
      deck.add(CardItem(id: idSecond, pairId: idOne, value: right));
    }
    return deck;
  }

  void shuffleCardsDeck() {
    cardsDeck.shuffle();
  }

  void printCardDeck() {
    _logger.i('Print all cards from deck:');
    for (var card in cardsDeck) {
      _logger.i(card.toString());
    }
  }
}
