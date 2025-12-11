# GameSessionManager - Detailed Documentation

## Overview

Abstract base class defining shared API and basic logic for all game modes. Extends `ChangeNotifier` for reactive UI updates.

## Properties (API Requirements)

- `currentStage: int?` - index of current stage (nullable)
- `currentType: StageType?` - type of current stage (enum: MC, Typed, Pairs)
- `completedCount: int` - number of completed stages
- `totalCount: int` - total number of stages in the session
- `isFinished: bool` - whether the session is finished
- `currentStageObject: GameStage?` - returns the current stage object

## Public Methods

### `void start(LevelInfo level)`
Starts the game session with the given level. Can be called multiple times to restart/retake a level.
- Generates stages via `generateStages()`
- Resets all state (`_currentStage = 0`, `_completedCount = 0`, `_isFinished = false`)
- Calls `notifyListeners()`

### `void skipCurrentStage()`
Skips the current stage if allowed by subclass rules.
- Checks if skip is allowed via `canSkipStage()`
- Throws `UnsupportedError` if skip not allowed
- Calls `nextStage()` with a skipped result

### `void nextStage(StageResult result)`
Advances to the next stage with the given result.
1. Validates session is not finished
2. Updates `completedCount` if not skipped
3. Calls `processStageResult()` for subclass processing
4. Checks `shouldFinish()`
5. If not finished: increments `currentStage`
6. Calls `notifyListeners()` to update UI

### `double getProgress()`
Returns progress as a value between 0.0 and 1.0.

## Abstract Methods (Must be Implemented by Subclasses)

### `List<GameStage> generateStages(LevelInfo level)`
Generates the list of stages for the given level. Defines stage generation logic specific to game mode.

### `bool canSkipStage()`
Determines if the current stage can be skipped. Defines skip rules specific to game mode.

### `bool shouldFinish()`
Determines if the session should finish based on current state. Defines finish conditions specific to game mode.

### `void processStageResult(StageResult result)`
Processes the stage result. Can be overridden for additional processing (e.g., tracking accuracy in Exam mode).

## Internal Logic

- Counter `completedCount` tracks completed stages
- Flag `isFinished` marks session completion
- Event dispatcher via `notifyListeners()` (from ChangeNotifier)
- Protection against calls when `isFinished=true` via `ensureNotFinished()`

## Class Hierarchy

```
GameSessionManager (abstract)
       ↓
    ┌──────────────────┐
    ↓                  ↓
PracticeSessionManager  ExamSessionManager
```
