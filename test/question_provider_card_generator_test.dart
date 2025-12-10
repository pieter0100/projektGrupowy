// filepath: test/question_provider_card_generator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/services/card_generator.dart';
import 'package:projekt_grupowy/models/cards/card_item.dart';

void main() {
  group('QuestionProvider - per level', () {
    test('getPairsQuestions returns correct type and unique multipliers', () {
      final qp = QuestionProvider.getPairsQuestions(level: 3, pairsAmount: 4);
      expect(qp.typeOfMultiplication, 3);
      expect(qp.multipliers.length, 4);
      expect(qp.multipliers.toSet().length, 4);
      expect(qp.multipliers.every((m) => m >= 1 && m <= 10), isTrue);
    });

    test('getMcQuestion and getTypedQuestion match the level', () {
      final mc = QuestionProvider.getMcQuestion(level: 5);
      expect(mc.prompt, contains('5 ×'));
      expect(mc.options.length, 4);
      expect(
        mc.correctIndex >= 0 && mc.correctIndex < mc.options.length,
        isTrue,
      );

      final typed = QuestionProvider.getTypedQuestion(level: 5);
      expect(typed.prompt, contains('5 ×'));
      expect(int.tryParse(typed.correctAnswer), isNotNull);
    });
  });

  group('CardGenerator - deck from provided questions', () {
    test('Generates correct pairs and pairId relationships', () {
      final qp = QuestionProvider.getPairsQuestions(level: 2, pairsAmount: 3);
      final gen = CardGenerator(questions: qp);
      final deck = gen.cardsDeck;

      expect(deck.length, 6); // 3 pairs -> 6 cards

      // Verify each multiplier results in exactly two cards forming a pair
      for (final m in qp.multipliers) {
        final left = '${qp.typeOfMultiplication}×$m';
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
