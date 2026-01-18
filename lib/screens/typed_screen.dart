import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/utils/constants.dart';

import 'package:projekt_grupowy/models/level/unlock_requirements.dart';
import 'package:projekt_grupowy/game_logic/round_managers/exam_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class TypedScreen extends StatefulWidget {
  final int level;

  const TypedScreen({
    super.key,
    required this.level,
  });

  @override
  TypedScreenState createState() => TypedScreenState();
}

class TypedScreenState extends State<TypedScreen> {
  late ExamSessionManager session;
  final TextEditingController _textController = TextEditingController();

  bool _showFeedback = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();

    session = ExamSessionManager();
    session.addListener(_listener);

    final levelInfo = LevelInfo(
      levelId: widget.level.toString(),
      levelNumber: widget.level,
      name: "Level ${widget.level}",
      description: "",
      unlockRequirements: UnlockRequirements(minPoints: 0),
      rewards: Rewards(points: 0),
      isRevision: false,
    );

    session.start(levelInfo);
  }

  void _listener() {
    if (session.isFinished) {
      context.go('/level/learn/exam/end?level=${widget.level}');
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    session.removeListener(_listener);
    _textController.dispose();
    super.dispose();
  }

  void onComplete(String value) {
    if (value.trim().isEmpty) return;

    final stage = session.currentStageObject!;
    final data = stage.data as TypedData;

    final userAnswer = int.tryParse(value.trim()) ?? -999999;
    final correctAnswer = data.correctAnswer;

    final isCorrect = userAnswer == correctAnswer;

    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
    });

    session.nextStage(
      StageResult(
        isCorrect: isCorrect,
        skipped: false,
        userAnswer: value.trim(),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() {
        _showFeedback = false;
        _textController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final stage = session.currentStageObject;

    if (stage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = stage.data as TypedData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Exam: Typed Questions",
          style: AppTextStyles.typedTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.typedAppBarBackground,
      ),

      body: Column(
        children: [
          const SizedBox(height: AppSizes.typedProgressTopMargin),
          ProgressBarWidget(value: session.getProgress()),
          const SizedBox(height: AppSizes.progressToTitleMargin),

          Padding(
            padding: const EdgeInsets.all(AppSizes.typedTitlePadding),
            child: const Text(
              'Type your answer',
              style: AppTextStyles.typedTitle,
            ),
          ),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      data.question,
                      style: AppTextStyles.typedQuestion,
                      textAlign: TextAlign.center,
                    ),

                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppSizes.typedFieldPaddingStart,
                        end: AppSizes.typedFieldPaddingEnd,
                        top: AppSizes.typedFieldPaddingTop,
                        bottom: AppSizes.typedFieldPaddingBottom,
                      ),
                      child: TextField(
                        controller: _textController,
                        enabled: !_showFeedback,
                        style: AppTextStyles.typedInput,
                        decoration: InputDecoration(
                          hintText: "Type the answer",
                          hintStyle: const TextStyle(
                            color: AppColors.typedHint,
                            fontSize: AppSizes.typedInputFontSize,
                          ),
                          filled: true,
                          fillColor: _showFeedback
                              ? (_isCorrect
                                  ? AppColors.typedInputCorrect
                                  : AppColors.typedInputWrong)
                              : AppColors.typedInputDefault,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.typedInputPaddingH,
                            vertical: AppSizes.typedInputPaddingV,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.typedInputBorderRadius,
                            ),
                            borderSide: _showFeedback
                                ? BorderSide(
                                    color: _isCorrect
                                        ? AppColors.typedBorderCorrect
                                        : AppColors.typedBorderWrong,
                                    width: AppSizes.typedInputBorderWidth,
                                  )
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.typedInputBorderRadius,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.typedFocusedBorder,
                              width: AppSizes.typedInputBorderWidth,
                            ),
                          ),
                        ),
                        onSubmitted: _showFeedback ? null : onComplete,
                        textInputAction: TextInputAction.done,
                        cursorColor: AppColors.typedHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
