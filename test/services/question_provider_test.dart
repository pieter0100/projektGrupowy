import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/services/question_provider.dart';

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
}
