import 'dart:math';

// Question models
class QuestionsPairs {
  final int typeOfMultiplication;
  final List<int> multipliers;
  QuestionsPairs({
    required this.typeOfMultiplication,
    required this.multipliers,
  });
}

class QuestionMC {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  QuestionMC({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });
}

class QuestionTyped {
  final String prompt;
  final String correctAnswer;
  QuestionTyped({required this.prompt, required this.correctAnswer});
}

class QuestionProvider {
  static QuestionsPairs getPairsQuestions({
    required int level,
    int pairsAmount = 3,
  }) {
    final type = _levelToType(level);
    final base = _randomUniqueNumbers(count: pairsAmount, maxInclusive: 10);
    return QuestionsPairs(typeOfMultiplication: type, multipliers: base);
  }

  static QuestionMC getMcQuestion({required int level}) {
    final type = _levelToType(level);
    final a = type;
    final b = Random().nextInt(10) + 1;
    final answer = (a * b).toString();
    final prompt = '$a × $b =';
    final options = <String>{answer};
    while (options.length < 4) {
      int option = Random().nextInt(10) + 1;
      if (option == b) continue;
      options.add((a * option).toString());
    }
    final opts = options.toList()..shuffle();
    final correctIndex = opts.indexOf(answer);
    return QuestionMC(
      prompt: prompt,
      options: opts,
      correctIndex: correctIndex,
    );
  }

  static QuestionTyped getTypedQuestion({required int level}) {
    final type = _levelToType(level);
    final b = Random().nextInt(10) + 1;
    return QuestionTyped(
      prompt: '$type × $b =',
      correctAnswer: (type * b).toString(),
    );
  }

  static int _levelToType(int level) {
    if (level <= 0) return 1;
    return level.clamp(1, 10);
  }

  static List<int> _randomUniqueNumbers({
    required int count,
    required int maxInclusive,
  }) {
    final rand = Random();
    final set = <int>{};
    while (set.length < count) {
      set.add(rand.nextInt(maxInclusive) + 1);
    }
    return set.toList();
  }
}
