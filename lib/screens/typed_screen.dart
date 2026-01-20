import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/game_logic/round_managers/exam_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';
import 'package:projekt_grupowy/utils/constants.dart';

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
  State<TypedScreen> createState() => _TypedScreenState();
}

class _TypedScreenState extends State<TypedScreen> {
  final TextEditingController _textController = TextEditingController();
  ExamSessionManager? _examManager;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _isSkipHighlighted = false;
  String? _hintText;

  @override
  void initState() {
    super.initState();
    if (!widget.isPracticeMode) {
      _examManager = ExamSessionManager();
      _startExam();
    }
  }

  void _startExam() {
    final levelData = LevelInfo(
      levelNumber: widget.level,
      levelId: widget.level.toString(),
      name: "Exam",
      description: "",
      unlockRequirements: UnlockRequirements(minPoints: 0, previousLevelId: null),
      rewards: Rewards(points: 0),
      isRevision: false,
    );
    _examManager!.start(levelData);
  }

  TypedData get _currentData => widget.isPracticeMode 
      ? widget.data! 
      : (_examManager!.currentStageObject!.data as TypedData);

  void _onSkip() {
    if (_showFeedback) return;
    
    setState(() {
      _isSkipHighlighted = true;
      _hintText = "Correct: ${_currentData.correctAnswer}";
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      widget.onResult?.call(StageResult.skipped());
      _resetUI();
    });
  }

  void _handleSubmit(String value) {
    if (value.trim().isEmpty || _showFeedback) return;
    final userAnswer = int.tryParse(value.trim());
    _isCorrect = userAnswer == _currentData.correctAnswer;

    setState(() => _showFeedback = true);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      
      if (widget.isPracticeMode) {
        widget.onResult?.call(_isCorrect 
            ? StageResult(isCorrect: true, skipped: false) 
            : StageResult.skipped());
      } else {
        _moveToNextExamStage(_isCorrect);
      }
      _resetUI();
    });
  }

  void _moveToNextExamStage(bool wasCorrect) {
    _examManager!.nextStage(StageResult(isCorrect: wasCorrect, skipped: false));
    
    if (_examManager!.isFinished) {
      context.go('/level/learn/exam/end?level=${widget.level}&score=${_examManager!.correctCount}');
    } else {
      setState(() {}); 
    }
  }

  void _resetUI() {
    setState(() {
      _showFeedback = false;
      _isSkipHighlighted = false;
      _hintText = null;
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPracticeMode) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/level/learn?level=${widget.level}');
              }
            },
          ),
          backgroundColor: AppColors.typedAppBarBackground,
          elevation: 0,
          centerTitle: true,
          title: Text("Multiply x ${widget.level}", style: AppTextStyles.practiceTitle),
        ),
        body: Column(
          children: [
            const SizedBox(height: AppSizes.practiceTopSpacing),
            ProgressBarWidget(value: _examManager!.getProgress()),
            Expanded(child: _buildMainContent()),
          ],
        ),
      );
    }
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.typedFieldPaddingStart),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.typedFieldPaddingTop),
            const Text('Type your answer', style: AppTextStyles.typedTitle),
            const SizedBox(height: AppSizes.screenPaddingLarge),
            Text(_currentData.question, style: AppTextStyles.typedQuestion, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.typedFieldPaddingTop),
            TextField(
              controller: _textController,
              enabled: !_showFeedback,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: AppTextStyles.typedInput,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: _hintText ?? "Answer...",
                hintStyle: const TextStyle(color: AppColors.typedHint),
                filled: true,
                fillColor: _showFeedback
                    ? (_isCorrect ? AppColors.typedInputCorrect : AppColors.typedInputWrong)
                    : AppColors.typedInputDefault,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.typedInputBorderRadius),
                  borderSide: _showFeedback
                      ? BorderSide(color: _isCorrect ? AppColors.typedBorderCorrect : AppColors.typedBorderWrong, width: AppSizes.typedInputBorderWidth)
                      : BorderSide.none,
                ),
              ),
              onSubmitted: _handleSubmit,
            ),
            
            if (widget.isPracticeMode) ...[
              const SizedBox(height: AppSizes.typedInputSpacing),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showFeedback ? null : _onSkip,
                  child: Text(
                    "Don't know?", 
                    style: AppTextStyles.typedSkip.copyWith(
                      decoration: _isSkipHighlighted ? TextDecoration.underline : TextDecoration.none
                    )
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.typedSkipBottomSpacing),
          ],
        ),
      ),
    );
  }
}