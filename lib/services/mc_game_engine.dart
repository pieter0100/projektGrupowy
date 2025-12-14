import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';

class MCGameEngine {
  late QuestionMC _question;
  int? _selectedIndex;
  final Function(StageResult)? onComplete;
  MCGameEngine({this.onComplete});

  void initialize(int level) {
    _question = QuestionProvider.getMcQuestion(level: level);
    _selectedIndex = null;
  }

  QuestionMC get question => _question;
  int get correctIndex => _question.correctIndex;
  String get correctAnswer => _question.options[_question.correctIndex];

  void selectOption(int optionIndex) {
    if (optionIndex < 0 || optionIndex >= _question.options.length) {
      throw RangeError('Invalid option index: $optionIndex');
    }

    if (_selectedIndex != null) {
      throw StateError('Answer already selected');
    }

    _selectedIndex = optionIndex;

    final isCorrect = optionIndex == _question.correctIndex;
    final selectedAnswer = _question.options[optionIndex];

    final result = StageResult(
      isCorrect: isCorrect,
      skipped: false,
      userAnswer: {
        'selectedIndex': optionIndex,
        'selectedAnswer': selectedAnswer,
      },
    );

    onComplete?.call(result);
  }

  /// Check if an answer was already selected
  bool get answerSelected => _selectedIndex != null;

  /// Skip is not allowed in MC - throws error
  void skip() {
    throw UnsupportedError('Skip is not allowed in Multiple Choice game');
  }

  /// Get the selected answer (or null if not selected)
  String? get selectedAnswer =>
      _selectedIndex != null ? _question.options[_selectedIndex!] : null;

  /// Get the current game state as a map
  Map<String, dynamic> getGameState() {
    return {
      'prompt': _question.prompt,
      'options': _question.options,
      'correctIndex': _question.correctIndex,
      'selectedIndex': _selectedIndex,
      'answerSelected': _selectedIndex != null,
    };
  }
}
