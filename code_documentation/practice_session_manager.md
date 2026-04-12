# PracticeSessionManager - Detailed Documentation

## Overview

Concrete implementation of game session logic for Practice mode. Extends `GameSessionManager`.

## Rules

- **Number of stages:** 6 (`totalCount = 6`)
- **Available types:** MC (Multiple Choice), Typed, Pairs
- **Type randomization:** Random with anti-series rule (never 3 same in a row)
- **Skip allowed for:** Typed only
- **Skip forbidden for:** MC, Pairs
- **Completion condition:** `completedCount == 6`

## Implementation Details

### `generateStages(LevelInfo level)`
Generates 6 stages with random types using anti-series rule.
- Clears stage type history
- For each stage: selects next type via `selectNextType()`
- Creates `GameStage` with type and data from `generateStageData()`

### `canSkipStage()`
Returns `true` only if `currentType == StageType.typed`, `false` otherwise.

### `shouldFinish()`
Returns `true` when `completedCount >= 6`.

### `processStageResult(StageResult result)`
No special processing in practice mode. Calls `super.processStageResult(result)`.

## Anti-Series Algorithm

### `selectNextType()`
Never allows 3 same types in a row:
1. Gets available types: MC, Typed, Pairs
2. If last 2 types in history are the same, removes that type from available options
3. Returns random selection from remaining types

Example:
- History: [MC, MC] → Next cannot be MC
- History: [Typed, MC] → All types available

## Stage Data Generation

### `generateStageData(StageType type, LevelInfo level)`
Generates stage data based on type:

### `generateMultipleChoiceData(LevelInfo level)`
Generates Multiple Choice stage data using QuestionProvider:
- Uses `QuestionProvider.getMcQuestion()` with level number
- Parses string options to int list
- Returns `MultipleChoiceData` with question, correct answer, and options

### `generateTypedData(LevelInfo level)`
Generates Typed stage data using QuestionProvider:
- Uses `QuestionProvider.getTypedQuestion()` with level number
- Returns `TypedData` with question prompt and correct answer
- Generates questions based on the multiplication table corresponding to the level

### `generatePairsData(LevelInfo level)`
Generates Pairs stage data using QuestionProvider and CardGenerator:
- Uses `QuestionProvider.getPairsQuestions()` with level number and 3 pairs
- Creates card deck using `CardGenerator`
- Returns `PairsData` with cards, pairs count, and multiplication table type
- Uses the level's multiplication table (not random)

## Acceptance Criteria

- Never 3 same types in a row
- Skip for Typed: does not increase `completedCount`
- After 6 completed → `isFinished == true`

## Testing Focus

- Skip + no counting for Typed
- Sequence completing 6 rounds
- Anti-series algorithm validation
