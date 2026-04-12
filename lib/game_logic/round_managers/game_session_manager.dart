import 'package:flutter/foundation.dart';
import 'package:projekt_grupowy/game_logic/stages/game_stage.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/models/level/stage_result.dart';
import 'package:projekt_grupowy/models/level/level.dart';

abstract class GameSessionManager extends ChangeNotifier {
  
  int? _currentStage;
  List<GameStage> stages = [];
  int _completedCount = 0;
  bool _isFinished = false;
    
  // GETTERS
  int? get currentStage => _currentStage;
  
  int get completedCount => _completedCount;
  
  int get totalCount => stages.length;  
  
  bool get isFinished => _isFinished;
  
  GameStage? get currentStageObject {
    if (_currentStage == null || _currentStage! >= stages.length) {
      return null;
    }
    return stages[_currentStage!];
  }
  
  StageType? get currentType {
    if (_currentStage == null || _currentStage! >= stages.length) {
      return null;
    }
    return stages[_currentStage!].type;
  }
  
  // starts the game session with the given level
  // generates stages and initializes the session
  // can be called multiple times to restart/retake a level
  void start(LevelInfo level) {
    // reset all state to allow restarting
    stages = generateStages(level);
    _currentStage = 0;
    _completedCount = 0;
    _isFinished = false;
    
    notifyListeners();
  }
  
  void skipCurrentStage() {
    ensureNotFinished();
    
    if (_currentStage == null) {
      throw StateError('No active stage to skip');
    }
    
    if (!canSkipStage()) {
      throw UnsupportedError('Skip is not allowed for current stage type');
    }
    
    nextStage(StageResult.skipped());
  }
  
  void nextStage(StageResult result) {
    ensureNotFinished();
    
    if (_currentStage == null) {
      throw StateError('No active stage');
    }
    
    // update completed count if not skipped (player completed the stage)
    if (!result.skipped) {
      _completedCount++;
    }
    
    // allow subclass to process the result
    processStageResult(result);
    
    if (shouldFinish()) {
      _isFinished = true;
      _currentStage = null;
    } else {
      // move to next stage
      _currentStage = _currentStage! + 1;

      // check if we exceeded the number of stages (player completed the last stage)
      if (_currentStage! >= stages.length) {
        _isFinished = true;
        _currentStage = null;
      }
    }
    
    notifyListeners();
  }
  
  // HELPER METHODS

  double getProgress() {
    if (totalCount == 0) return 0.0;
    return _completedCount / totalCount;
  }
  
  void ensureNotFinished() {
    if (_isFinished) {
      throw StateError('Cannot perform operation on a finished session');
    }
  }
  
  // ABSTRACT METHODS
  
  // generates the list of stages for the given level
  List<GameStage> generateStages(LevelInfo level);
  
  // determines if the current stage can be skipped
  bool canSkipStage();
  
  // determines if the session should finish based on current state
  bool shouldFinish();
  
  // processes the stage result.
  // can be overridden by subclasses for additional processing (e.g., tracking accuracy).
  void processStageResult(StageResult result) {
    // default implementation does nothing
    // subclasses can override to add custom logic
  }
}
