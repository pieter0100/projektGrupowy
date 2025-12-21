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

### `validateAnswer(dynamic userAnswer, {int? answerTime})`
Convenience method that validates typed answers:
- Handles both `int` and `String` inputs (uses `TypedValidator.parseAnswer()`)
- Uses `TypedValidator.checkAnswer()` to validate
- Returns `StageResult` or `null` if parsing/validation fails

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

### `_generateTypedData(LevelInfo level, int stageIndex)`
Generates Typed stage data:
- TODO: Will use `TypedQuestionGenerator` (to be implemented)
- Currently throws `UnimplementedError`
- Will generate questions based on level configuration

## Acceptance Criteria

- `currentType` always Typed
- Skip → error (`UnsupportedError`)
- Accuracy correctly calculated

## Testing Focus

- Skip causes exception
- No randomization (all stages are Typed)
- Accuracy calculation correctness
