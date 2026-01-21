import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

import 'package:projekt_grupowy/game_logic/round_managers/exam_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';

class TypedScreen extends StatefulWidget {
  final int level;
  final bool isPracticeMode;
  final TypedData? data;
  final Function(StageResult)? onResult;

  const TypedScreen({
    super.key,
    required this.level,
    required this.isPracticeMode,
    this.data,
    this.onResult,
  });

  @override
  TypedScreenState createState() => TypedScreenState();
}

class TypedScreenState extends State<TypedScreen> {
  ExamSessionManager? sessionManager;

  final TextEditingController _textController = TextEditingController();

  String questionText = "Loading...";
  String placeHolder = "Type the answer";
  bool _showFeedback = false;
  bool _isCorrect = false;
  // Nowa zmienna, aby rozróżnić błąd od "nie wiem"
  bool _isDontKnow = false;

  @override
  void initState() {
    super.initState();

    if (widget.data != null) {
      questionText = widget.data!.question;
    } else {
      sessionManager = ExamSessionManager();

      final currentLevelInfo = LevelInfo(
        levelId: widget.level.toString(),
        levelNumber: widget.level,
        name: "Level ${widget.level}",
        description: "Exam level",
        unlockRequirements: UnlockRequirements(minPoints: 0),
        rewards: Rewards(points: 0),
        isRevision: false,
      );

      sessionManager!.start(currentLevelInfo);
      _loadCurrentQuestion();

      sessionManager!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _loadCurrentQuestion() {
    if (sessionManager?.currentStageObject != null) {
      final data = sessionManager!.currentStageObject!.data as TypedData;
      setState(() {
        questionText = data.question;
        _textController.clear();
        _isDontKnow = false; // Reset flagi przy nowym pytaniu
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    sessionManager?.dispose();
    super.dispose();
  }

  void onDontKnow() async {
    // 1. Pobierz poprawną odpowiedź
    int correctAnswer;
    if (widget.data != null) {
      correctAnswer = widget.data!.correctAnswer;
    } else if (sessionManager != null &&
        sessionManager!.currentStageObject != null) {
      final currentData = sessionManager!.currentStageObject!.data as TypedData;
      correctAnswer = currentData.correctAnswer;
    } else {
      return;
    }

    // 2. Wpisz ją w pole i pokaż feedback
    setState(() {
      _textController.text = correctAnswer.toString();
      _showFeedback = true;
      _isCorrect = false;
      _isDontKnow = true; // Oznaczamy, że to "Don't know" (nie będzie czerwone)
    });

    // 3. Odczekaj chwilę
    await Future.delayed(const Duration(milliseconds: 1500));

    // 4. Przejdź dalej (nadal traktujemy jako błąd w logice gry)
    _processResult(userAnswer: correctAnswer, isCorrect: false);
  }

  void onComplete(String value) async {
    if (value.trim().isEmpty) return;

    final userAnswer = int.tryParse(value.trim());
    bool isCorrect = false;

    if (widget.data != null) {
      isCorrect = userAnswer == widget.data!.correctAnswer;
    } else if (sessionManager != null) {
      final currentData = sessionManager!.currentStageObject!.data as TypedData;
      isCorrect = userAnswer == currentData.correctAnswer;
    }

    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
      _isDontKnow = false; // To jest normalna odpowiedź użytkownika
    });

    await Future.delayed(const Duration(milliseconds: 500));

    _processResult(userAnswer: userAnswer, isCorrect: isCorrect);
  }

  void _processResult({
    required int? userAnswer,
    required bool isCorrect,
  }) async {
    final result = StageResult(
      isCorrect: isCorrect,
      skipped: !isCorrect && widget.isPracticeMode,
      userAnswer: userAnswer,
    );

    if (widget.onResult != null) {
      widget.onResult!(result);
    } else if (sessionManager != null) {
      sessionManager!.nextStage(result);

      if (sessionManager!.isFinished) {
        const userId = "user1";
        await sessionManager!.saveProgress(userId, widget.level.toString());

        if (mounted) {
          context.go(
            '/level/learn/exam/end?level=${widget.level}&score=${sessionManager!.correctCount}',
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _showFeedback = false;
            _loadCurrentQuestion();
          });
        }
      }
    }
  }

  Widget _buildContent() {
    // Logika koloru tła:
    // Jeśli feedback jest włączony:
    //  - Jeśli to "Don't Know" -> Domyślny (neutralny/szary)
    //  - Jeśli Poprawne -> Zielony
    //  - Jeśli Błędne -> Czerwony
    // W przeciwnym razie -> Domyślny
    Color fillColor;
    if (_showFeedback) {
      if (_isDontKnow) {
        fillColor = AppColors.typedInputDefault;
      } else {
        fillColor = _isCorrect
            ? AppColors.typedInputCorrect
            : AppColors.typedInputWrong;
      }
    } else {
      fillColor = AppColors.typedInputDefault;
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              questionText,
              style: AppTextStyles.typedQuestion,
              textAlign: TextAlign.center,
            ),

            // Kontener z paddingiem zawierający TextField i Przycisk
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Wyrównanie do prawej
                children: [
                  TextField(
                    controller: _textController,
                    enabled: !_showFeedback,
                    style: AppTextStyles.typedInput,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: placeHolder,
                      filled: true,
                      fillColor: fillColor, // Używamy nowej logiki kolorów
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.typedInputBorderRadius,
                        ),
                      ),
                    ),
                    onSubmitted: _showFeedback ? null : onComplete,
                    textInputAction: TextInputAction.done,
                  ),

                  // Przycisk "Don't know" - tylko w trybie Practice i gdy nie ma jeszcze wyniku
                  if (widget.isPracticeMode && !_showFeedback)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: onDontKnow,
                        child: const Text(
                          "Don't know",
                          style: TextStyle(
                            color: AppColors.typedSkipText,
                            fontSize: 16, // Nieco mniejsza czcionka
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data != null) {
      return _buildContent();
    }

    double progress = 0.0;
    if (sessionManager != null && sessionManager!.totalCount > 0) {
      progress = sessionManager!.completedCount / sessionManager!.totalCount;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Exam: Level ${widget.level}"),
        backgroundColor: AppColors.typedAppBarBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/level/learn?level=${widget.level}'),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSizes.typedProgressTopMargin),
            child: ProgressBarWidget(value: progress),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.typedTitlePadding),
            child: Text(
              'Question ${sessionManager!.completedCount + 1} / ${sessionManager!.totalCount}',
              style: AppTextStyles.typedTitle,
            ),
          ),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
