import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/services/card_generator.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';

void main() {
  group('CardGenerator - deck from provided questions', () {
    test('Generates correct pairs and pairId relationships', () {
      final qp = QuestionProvider.getPairsQuestions(level: 2, pairsAmount: 3);
      final gen = CardGenerator(questions: qp);
      final deck = gen.cardsDeck;

      expect(deck.length, 6); // 3 pairs -> 6 cards

      // Verify each multiplier results in exactly two cards forming a pair
      for (final m in qp.multipliers) {
        final left = '${qp.typeOfMultiplication} × $m';
        final right = '${qp.typeOfMultiplication * m}';
        final leftCard = deck.firstWhere(
          (c) => c.value == left,
          orElse: () => CardItem(id: '', pairId: '', value: ''),
        );
        final rightCard = deck.firstWhere(
          (c) => c.value == right,
          orElse: () => CardItem(id: '', pairId: '', value: ''),
        );
        expect(leftCard.id.isNotEmpty, isTrue);
        expect(rightCard.id.isNotEmpty, isTrue);
        expect(leftCard.pairId, rightCard.id);
        expect(rightCard.pairId, leftCard.id);
      }
    });
  });
}
