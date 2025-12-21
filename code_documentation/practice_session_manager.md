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
- For each stage: selects next type via `_selectNextType()`
- Creates `GameStage` with type and data from `_generateStageData()`

### `canSkipStage()`
Returns `true` only if `currentType == StageType.typed`, `false` otherwise.

### `shouldFinish()`
Returns `true` when `completedCount >= 6`.

### `validateAnswer(dynamic userAnswer, {int? answerTime})`
Convenience method that validates answers for current stage:
- **MC stages:** Uses `MCValidator.checkAnswer()`
- **Typed stages:** Uses `TypedValidator.checkAnswer()` (handles both int and String input)
- **Pairs stages:** Throws `UnsupportedError` (must use `PairsRoundManager` directly)

Returns `StageResult` with validation results or `null` if validation fails.

## Anti-Series Algorithm

### `_selectNextType()`
Never allows 3 same types in a row:
1. Gets available types: MC, Typed, Pairs
2. If last 2 types in history are the same, removes that type from available options
3. Returns random selection from remaining types

Example:
- History: [MC, MC] → Next cannot be MC
- History: [Typed, MC] → All types available

## Stage Data Generation

### `_generateStageData(StageType type, LevelInfo level)`
Generates stage data based on type:

**Multiple Choice:**
- TODO: Will use `MCQuestionGenerator` (to be implemented)
- Currently throws `UnimplementedError`

**Typed:**
- TODO: Will use `TypedQuestionGenerator` (to be implemented)
- Currently throws `UnimplementedError`

**Pairs:**
- Uses existing `CardGenerator`
- Creates 3 pairs (6 cards)
- Based on random multiplication table (1-10)

## Acceptance Criteria

- Never 3 same types in a row
- Skip for Typed: does not increase `completedCount`
- After 6 completed → `isFinished == true`

## Testing Focus

- Skip + no counting for Typed
- Sequence completing 6 rounds
- Anti-series algorithm validation
