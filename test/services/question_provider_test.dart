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

  group('QuestionProvider - getTypedQuestionsForExam', () {
    test('returns 10 unique, shuffled questions for level 1', () {
      final questions = QuestionProvider.getTypedQuestionsForExam(level: 1);
      expect(questions.length, 10);
      final prompts = questions.map((q) => q.prompt).toSet();
      expect(prompts.length, 10);
      for (int i = 1; i <= 10; i++) {
        expect(prompts.contains('1 × $i ='), isTrue);
      }
    });

    test('returns correct number of questions if numberOfQuestions < 10', () {
      final questions = QuestionProvider.getTypedQuestionsForExam(
        level: 2,
        numberOfQuestions: 5,
      );
      expect(questions.length, 5);
      final prompts = questions.map((q) => q.prompt).toSet();
      expect(prompts.length, 5);
      for (final q in questions) {
        expect(q.prompt.startsWith('2 ×'), isTrue);
      }
    });

    test('questions are shuffled (order is not always the same)', () {
      final list1 = QuestionProvider.getTypedQuestionsForExam(level: 3);
      final list2 = QuestionProvider.getTypedQuestionsForExam(level: 3);
      final sameOrder = List.generate(
        10,
        (i) => list1[i].prompt == list2[i].prompt,
      ).every((x) => x);
      expect(sameOrder, isFalse);
    });
  });
}
