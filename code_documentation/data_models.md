# Data Models - Detailed Documentation

## Overview

Data models used throughout the game session management system. These models only store data/configuration, not gameplay state or logic.

## StageType (Enum)

Represents the type of stage in a game session.

```dart
enum StageType {
  multipleChoice,  // MC - Question with 4 answer options
  typed,           // Typed - Question requiring typed input
  pairs            // Pairs - Matching pairs of cards
}
```

## StageResult

Represents the result of a single stage.

### Properties

- `bool isCorrect` - Whether the answer was correct
- `bool skipped` - Whether the stage was skipped (default: false)
- `int? answerTime` - Time taken to answer in milliseconds (optional)
- `dynamic userAnswer` - User's answer (supports various answer formats)

### Factory Constructor

```dart
StageResult.skipped()
```
Creates a `StageResult` for a skipped stage with `isCorrect: false` and `skipped: true`.

## GameStage

Represents a single stage in the game session. Combines stage type with its specific data.

### Properties

- `StageType type` - The type of this stage (MC, Typed, or Pairs)
- `StageData data` - The data specific to this stage type

## StageData (Abstract)

Abstract base class for stage-specific data. Only stores configuration/data, not gameplay state or logic.

### MultipleChoiceData

Data for Multiple Choice stage.

**Properties:**
- `String question` - The question to display (e.g., "2 × 7 = ?")
- `int correctAnswer` - The correct answer (e.g., 14)
- `List<int> options` - List of answer options including correct one (e.g., [14, 12, 16, 18])

### TypedData

Data for Typed stage.

**Properties:**
- `String question` - The question to display (e.g., "5 × 3 = ?")
- `int correctAnswer` - The correct answer (e.g., 15)

### PairsData

Data for Pairs stage.

**Properties:**
- `List<CardItem> cards` - List of shuffled cards to match (pairs of multiplication problems and answers)
- `int pairsCount` - Number of pairs in this stage
- `int typeOfMultiplication` - The multiplication table number (e.g., 2 for 2× table)

**Note:** Gameplay state (matched pairs, attempts, selected cards) is managed by `PairsRoundManager`, not stored here.

## Separation of Concerns

**StageData** models follow the principle of separation of concerns:
- Store: Questions, answers, options, configuration
- Don't store: Game state, progress, user selections
- Don't contain: Validation logic, game rules

Gameplay logic is handled by:
- **Validators** for MC and Typed (`MCValidator`, `TypedValidator`)
- **PairsRoundManager** for Pairs matching logic
- **GameSessionManager** for session orchestration
