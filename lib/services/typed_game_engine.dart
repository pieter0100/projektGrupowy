import 'package:projekt_grupowy/services/question_provider.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:logger/logger.dart';

class TypedGameEngine {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  late QuestionTyped _question;
  String? _userAnswer;
  bool _skipped = false;
  final Function(StageResult)? onComplete;
  TypedGameEngine({this.onComplete});

  void initialize(int level) {
    _question = QuestionProvider.getTypedQuestion(level: level);
    _userAnswer = null;
    _skipped = false;
  }

  QuestionTyped get question => _question;
  String get correctAnswer => _question.correctAnswer;

  void submitAnswer(String userInput) {
    if (_skipped) {
      throw StateError('Cannot submit answer after skip');
    }

    _userAnswer = userInput;

    final normalizedInput = _normalizeAnswer(userInput);
    final normalizedCorrect = _normalizeAnswer(_question.correctAnswer);

    final isCorrect = normalizedInput == normalizedCorrect;

    final result = StageResult(
      isCorrect: isCorrect,
      skipped: false,
      userAnswer: userInput,
    );

    onComplete?.call(result);
  }

  void skip() {
    if (_userAnswer != null) {
      throw StateError('Cannot skip after answer was submitted');
    }

    _skipped = true;

    final result = StageResult(
      isCorrect: false,
      skipped: true,
      userAnswer: {'correctAnswer': _question.correctAnswer},
    );
    onComplete?.call(result);
  }

  String _normalizeAnswer(String answer) {
    return answer.trim().toLowerCase();
  }

  /// Get the current game state as a map
  Map<String, dynamic> getGameState() {
    return {
      'question': _question.prompt,
      'userAnswer': _userAnswer,
      'skipped': _skipped,
      'correctAnswer': _question.correctAnswer,
    };
  }

  /// Logs the current game state
  void logGameState() {
    Map<String, dynamic> state = getGameState();
    _logger.i('''
    Typed Game State:
    Question: ${state['question']}
    User Answer: ${state['userAnswer']}
    Correct Answer: ${state['correctAnswer']}
    Skipped: ${state['skipped']}
    ''');
  }

  /// Logs a custom message
  void logMessage(String message) {
    _logger.i(message);
  }
}
