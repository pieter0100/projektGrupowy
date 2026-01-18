import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/services/typed_game_engine.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class TypedScreen extends StatefulWidget {
  final int level;
  final bool isPracticeMode;

  const TypedScreen({
    super.key,
    required this.level,
    required this.isPracticeMode,
  });

  @override
  TypedScreenState createState() => TypedScreenState();
}

class TypedScreenState extends State<TypedScreen> {
  final engine = TypedGameEngine(
    onComplete: (result) {
      log('Correct: ${result.isCorrect}');
      log('Answer: ${result.userAnswer}');
    },
  );
  String placeHolder = "Type the answer";
  bool _isSkipHighlighted = false;
  String question = "Loading...";

  // Feedback states
  bool _showFeedback = false;
  bool _isCorrect = false;
  final TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    engine.initialize(widget.level);
    question = engine.question.prompt;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void onSkip() {
    if (!widget.isPracticeMode) {
      return;
    }

    engine.skip();

    setState(() {
      _isSkipHighlighted = true;
      placeHolder = engine.question.correctAnswer;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSkipHighlighted = false;
          placeHolder = "Type the answer";
        });
      }
    });
  }

  void onComplete(String value) {
    if (value.trim().isEmpty) return;

    // Get the result before submitting to engine
    final userAnswer = int.tryParse(value.trim()) ?? 0;
    final correctAnswer = int.parse(engine.question.correctAnswer);
    final isCorrect = userAnswer == correctAnswer;

    // Show visual feedback only in practice mode
    if (widget.isPracticeMode) {
      setState(() {
        _showFeedback = true;
        _isCorrect = isCorrect;
      });
    }

    // Submit to engine
    engine.submitAnswer(value);

    // Hide feedback after 1 second and move to next question
    final delayDuration = widget.isPracticeMode
        ? const Duration(seconds: 1)
        : const Duration(milliseconds: 100); // Minimal delay for exam mode

    Future.delayed(delayDuration, () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
          _textController.clear();
          // Update question for next round
          question = engine.question.prompt;
        });

        // TEMPORARY: Navigate back to learn screen after answering
        // TODO: Remove this and implement proper session flow
        context.go('/level/learn?level=${widget.level}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("(np Multiply x 2) dane pobrane"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        backgroundColor:AppColors.typedAppBarBackground,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: AppSizes.typedProgressTopMargin),
            child: ProgressBarWidget(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.typedTitlePadding),
            child: Text('Type your answer', style: AppTextStyles.typedTitle),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      question,
                      style: AppTextStyles.typedQuestion,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.directional(
                        start: AppSizes.typedFieldPaddingStart,
                        end: AppSizes.typedFieldPaddingEnd,
                        top: AppSizes.typedFieldPaddingTop,
                        bottom: AppSizes.typedFieldPaddingBottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _textController,
                            enabled: !_showFeedback, // Disable during feedback
                            style: AppTextStyles.typedInput,
                            decoration: InputDecoration(
                              hintText: placeHolder,
                              hintStyle: TextStyle(
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
                                borderRadius: BorderRadius.circular(AppSizes.typedInputBorderRadius),
                                borderSide: _showFeedback
                                    ? BorderSide(
                                        color: _isCorrect
                                            ? AppColors.typedBorderCorrect
                                            : AppColors.typedBorderWrong,
                                        width: AppSizes.typedInputBorderWidth,
                                      )
                                    : BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.typedInputBorderRadius),
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
                                borderRadius: BorderRadius.circular(AppSizes.typedInputBorderRadius),
                                borderSide: BorderSide(
                                  color: _showFeedback
                                      ? (_isCorrect ? AppColors.typedBorderCorrect : AppColors.typedBorderWrong)
                                      : AppColors.typedFocusedBorder,
                                  width: AppSizes.typedInputBorderWidth,
                                ),
                              ),
                            ),
                            onSubmitted: _showFeedback ? null : onComplete,
                            textInputAction: TextInputAction.done,
                            cursorColor: AppColors.typedHint,
                          ),
                          SizedBox(height: AppSizes.typedInputSpacing),
                          if (widget.isPracticeMode)
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: onSkip,
                                child: Text(
                                  "Don't know?",
                                  style: AppTextStyles.typedSkip.copyWith( 
                                    decoration: _isSkipHighlighted 
                                      ? TextDecoration.underline 
                                      : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: AppSizes.typedSkipBottomSpacing),
                        ],
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
