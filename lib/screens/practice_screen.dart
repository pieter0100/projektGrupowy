import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/game_logic/round_managers/practice_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';

import 'package:projekt_grupowy/screens/match_pairs_screen.dart';
import 'package:projekt_grupowy/screens/MC_screen.dart';
import 'package:projekt_grupowy/screens/typed_screen.dart';

import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class PracticeScreen extends StatefulWidget {
  final String? level;

  const PracticeScreen({super.key, this.level});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late PracticeSessionManager sessionManager;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _startNewSession();
  }

  void _startNewSession() {
    sessionManager = PracticeSessionManager();
    sessionManager.addListener(_sessionListener);

    final int levelNum = int.tryParse(widget.level ?? '1') ?? 1;

    final levelData = LevelInfo(
      levelNumber: levelNum,
      levelId: widget.level ?? "1",
      name: "Level $levelNum",
      description: "Practice multiplication",
      unlockRequirements: UnlockRequirements(
        minPoints: 0,
        previousLevelId: null,
      ),
      rewards: Rewards(points: 0),
      isRevision: false,
    );

    sessionManager.start(levelData);
    setState(() => _initialized = true);
  }

  void _sessionListener() {
    if (sessionManager.isFinished) {
      context.go('/level/learn/practice/end?level=${widget.level}');
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    sessionManager.removeListener(_sessionListener);
    sessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentStage = sessionManager.currentStageObject;
    if (currentStage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: AppBar(
        backgroundColor: AppColors.practiceAppBarBackground,
        elevation: 0,
        title: Text(
          "Task ${sessionManager.completedCount + 1} / ${sessionManager.totalCount}",
          style: AppTextStyles.practiceTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.practiceCloseIcon),
          onPressed: () => context.go('/level/learn?level=${widget.level}'),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: AppSizes.practiceTopSpacing),
          ProgressBarWidget(value: sessionManager.getProgress()),
          const SizedBox(height: AppSizes.practiceProgressSpacing),

          Expanded(
            child: _buildCurrentGame(currentStage),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentGame(GameStage stage) {
    void onComplete() {
      sessionManager.nextStage(
        StageResult(
          isCorrect: true,
          skipped: false,
        ),
      );
    }

    switch (stage.type) {
      case StageType.multipleChoice:
        return McScreen(
          key: ValueKey(sessionManager.currentStage),
          data: stage.data as MultipleChoiceData,
          onSuccess: onComplete,
        );

      case StageType.typed:
        case StageType.typed:
          return TypedScreen(
            key: ValueKey(sessionManager.currentStage),
            level: int.tryParse(widget.level ?? '1') ?? 1,
            isPracticeMode: true,
            data: stage.data as TypedData,
            onResult: (result) {
              sessionManager.nextStage(result);
            },
          );

      case StageType.pairs:
        return MatchPairsScreen(
          key: ValueKey(sessionManager.currentStage),
          data: stage.data as PairsData,
          onSuccess: onComplete,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
