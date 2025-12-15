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

## Result Saving

### `saveExamResult(String userId, LevelInfo level)`

Saves the exam result to local storage after the exam session is finished.

**Behavior:**
- **Score:** Equals `correctCount` (number of correct answers, max 10)
- **Completion requirement:** Level is completed ONLY if all 10 answers are correct (100% accuracy required)
- **Failed attempts:** If not 100%, the level is NOT marked as completed and user must retake the exam
- **Attempts counter:** Increments on each save
- **Best score:** Updates only if the new score is higher than the existing one
- **Timestamps:** Updates `lastPlayedAt` on every attempt; sets `firstCompletedAt` only on first completion

**Parameters:**
- `userId` - User identifier
- `level` - Level information

**Throws:**
- `StateError` - If called before the session is finished (`isFinished == false`)

**Implementation details:**
- Creates or updates a `LevelProgress` entry in local storage via `LocalSaves`
- For existing progress: updates fields using `copyWith()` while preserving unchanged values
- For new progress: creates a fresh `LevelProgress` instance
- Uses `shouldSetFirstCompletion` flag to avoid duplicate condition checks
