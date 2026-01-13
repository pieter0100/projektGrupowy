# ExamSessionManager - Detailed Documentation

## Overview

Concrete implementation of game session logic for Exam mode. Extends `GameSessionManager`.

## Rules

- **Number of stages:** 10 (`totalCount = 10`)
- **Stage type:** `currentType = Typed` always (no randomization)
- **Skip:** FORBIDDEN - `skipCurrentStage()` throws error
- **Completion condition:** `completedCount == 10`
- **Tracks accuracy:** Counts correct answers for accuracy calculation

## Implementation Details

### `generateStages(LevelInfo level)`
Generates 10 Typed stages.
- Resets `_correctCount = 0`
- Creates 10 `GameStage` objects with `StageType.typed`
- Uses `_generateTypedData()` for each stage

### `canSkipStage()`
Always returns `false`. Skip is never allowed in Exam mode.

### `shouldFinish()`
Returns `true` when `completedCount >= 10`.

### `processStageResult(StageResult result)`
Tracks correct answers for accuracy calculation.
- If `result.isCorrect == true`: increments `_correctCount`
- Calls `super.processStageResult(result)` for base functionality

### Removed: `validateAnswer()`
This method was removed from the implementation as answer validation is handled by the UI layer and result is passed as `StageResult` to `nextStage()`.

## Accuracy Tracking

### Properties
- `correctCount: int` - Number of correct answers
- `getAccuracy(): double` - Returns accuracy as value between 0.0 and 1.0

### Calculation
```dart
accuracy = correctCount / totalCount
```

Example: 7 correct out of 10 = 0.7 (70%)

## Stage Data Generation

### `_generateTypedData(LevelInfo level)`
Generates Typed stage data using QuestionProvider:
- Uses `QuestionProvider.getTypedQuestion()` with level number
- Returns `TypedData` with question prompt and correct answer
- Generates questions based on the multiplication table corresponding to the level

## Acceptance Criteria

- `currentType` always Typed
- Skip → error (`UnsupportedError`)
- Accuracy correctly calculated

## Testing Focus

- Skip causes exception
- No randomization (all stages are Typed)
- Accuracy calculation correctness
