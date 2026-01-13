import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importy Managerów
import 'package:projekt_grupowy/game_logic/round_managers/practice_session_manager.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';

// Importy Twoich istniejących plików (używamy ich jako widżetów)
import 'package:projekt_grupowy/screens/match_pairs_screen.dart';
import 'package:projekt_grupowy/screens/MC_screen.dart';
import 'package:projekt_grupowy/screens/typed_screen.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

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
    unlockRequirements: [],
    rewards: [],
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
    if (!_initialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentStage = sessionManager.currentStageObject;
    if (currentStage == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text("Zadanie ${sessionManager.completedCount + 1} / ${sessionManager.totalCount}"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/level/learn?level=${widget.level}'),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ProgressBarWidget(value: sessionManager.getProgress()),
          const SizedBox(height: 20),
          Expanded(
            child: _buildCurrentGameMode(currentStage),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentGameMode(GameStage stage) {
    // Funkcja wywoływana po poprawnym rozwiązaniu
    void onComplete() {
      sessionManager.nextStage(StageResult(value: true, skipped: false));
    }

    // Mapowanie StageType na Twoje pliki
    switch (stage.type) {
      case StageType.multipleChoice:
        return MCScreen(
          data: stage.data as MultipleChoiceData, 
          onSuccess: onComplete
        );
      case StageType.typed:
        return TypedScreen( // Zakładam, że tak nazywa się klasa w typed_screen.dart
          data: stage.data as TypedData, 
          onSuccess: onComplete
        );
      case StageType.pairs:
        return MatchPairsScreen( // Twój stary ekran parowania
          data: stage.data as PairsData, 
          onSuccess: onComplete
        );
    }
  }
}