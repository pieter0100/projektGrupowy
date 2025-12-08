## Overview

Instead of a single  `RoundManager`, we have a system of modules working together, which facilitates the development and maintenance of the application.

### Stage types

System supports multiple stage types, including Multiple Choice (MC), Typed, and Pairs, each with distinct gameplay mechanics.

#### 1. Multiple Choice (MC)
- Question with 4 answer options, only one of which is correct
- Immediate feedback on correctness

#### 2. Typed
- Question requiring typed input
- Player types the answer
- Option to skip in Practice mode
- Strict answer validation

#### 3. Pairs
- Matching pairs of cards
- Finding pairs of matching cards
- Counting attempts

### System architecture

#### Class hierarchy

```
GameSessionManager (abstract)
       ↓
    ┌──────────────────┐
    ↓                  ↓
PracticeSessionManager  ExamSessionManager
```

### `GameSessionManager` Responsibilities

Defines shared API and basic logic for all game modes. Extends `ChangeNotifier` for reactive UI updates.

**Properties (API Requirements):**
- `currentStage: int?` - index of current stage (nullable)
- `currentType: StageType?` - type of current stage (enum: MC, Typed, Pairs)
- `completedCount: int` - number of completed stages
- `totalCount: int` - total number of stages in the session
- `isFinished: bool` - whether the session is finished

**Public methods (API Requirements):**
- `void start(Level level)` - starts the game session
- `void skipCurrentStage()` - skips current stage (if allowed)
- `void nextStage(StageResult result)` - advances to next stage with result

**Additional helper methods:**
- `GameStage? getCurrentStage()` - returns the current stage object
- `double getProgress()` - returns progress (0.0 - 1.0)

**Abstract methods (to be implemented in subclasses):**
- Game type selection logic
- Skip rules (`canSkipStage()`)
- Finish conditions (`shouldFinish()`)

**Internal logic (Abstract base contains):**
- Counter `completedCount`
- Flag `isFinished`
- Event dispatcher via `notifyListeners()` (from ChangeNotifier)
- Protection against calls when `isFinished=true`

**Subclasses implement:**
- Game type selection
- Skip rules
- Finish conditions

---

#### **PracticeSessionManager** (concrete implementation)

**Rules:**
- **Number of stages:** 6 (`totalCount = 6`)
- **Available types:** MC, Typed, Pairs
- **Type randomization:** Random with anti-series rule (never 3 same in a row)
- **Skip allowed for:** Typed only
- **Skip forbidden for:** MC, Pairs
- **Completion condition:** `completedCount == 6`

**`skipCurrentStage()` logic:**
```
- If currentType == Typed: allowed
- If currentType == MC or Pairs: throw error
```

**`nextStage(StageResult result)` logic:**
```
1. If result.skipped == false → completedCount++
2. If completedCount == 6 → isFinished = true
3. Otherwise: randomize next type (avoiding 3× same in row) and emit event
```

**Anti-series algorithm:**
```
When generating next type:
- Check last 2 types
- If both same, exclude that type from random selection
- Ensures never 3 same types in a row
```

---

#### **ExamSessionManager** (concrete implementation)

**Zasady (Rules):**
- **Number of stages:** 10 (`totalCount = 10`)
- **Stage type:** `currentType = Typed` always (no randomization)
- **Skip:** FORBIDDEN - `skipCurrentStage()` throws error
- **Completion condition:** `completedCount == 10`

**Collected data:**
- Counter of correct answers (`correctCount`)
- `getAccuracy()` method returns `correctCount / totalCount`

**`skipCurrentStage()` logic:**
```
throw UnsupportedError('Skip is not allowed in Exam mode');
```

**`nextStage(StageResult result)` logic:**
```
1. If result.isCorrect == true:
   - correctCount++
2. completedCount++
3. If completedCount >= 10:
   - isFinished = true
4. Emit event (notifyListeners)
```

**Acceptance criteria:**
- `currentType` always Typed
- `skip` → error
- accuracy correctly calculated

---

## Data Models
- `StageType` (enum) - represents type of stage
- `StageResult` - represents result of a single stage
- `GameStage` - represents a single stage in the game (type + data)
- `StageData` (abstract) - base class for stage-specific data
  - `MultipleChoiceData` - data for MC stage
  - `TypedData` - data for Typed stage
  - `PairsData` - data for Pairs stage

### **StageType** (enum)
```dart
enum StageType {
  multipleChoice,  // MC
  typed,           // Typed
  pairs            // Pairs
}
```

### **StageResult**
Represents result of a single stage.

```dart
class StageResult {
  final bool isCorrect;      // was the answer correct
  final bool skipped;        // was the stage skipped
  final int? answerTime;     // time taken to answer in ms (optional)
  final dynamic userAnswer;  // user's answer
  
  StageResult({
    required this.isCorrect,
    this.skipped = false,
    this.answerTime,
    this.userAnswer,
  });
}
```

### **GameStage**
Represents a single stage in the game.

```dart
class GameStage {
  final StageType type;
  final StageData data;
  
  GameStage({
    required this.type,
    required this.data,
  });
}
```

### **StageData** (abstract)
Base class for stage-specific data.

```dart
abstract class StageData {}

class MultipleChoiceData extends StageData {
  final String question;          // "2 × 7 = ?"
  final int correctAnswer;        // 14
  final List<int> options;        // [14, 12, 16, 18]
  
  MultipleChoiceData({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}

class TypedData extends StageData {
  final String question;          // "5 × 3 = ?"
  final int correctAnswer;        // 15
  
  TypedData({
    required this.question,
    required this.correctAnswer,
  });
}

class PairsData extends StageData {
  final List<CardItem> cards;     // List of CardItems to match
  final int pairsCount;           // Number of pairs
  
  PairsData({
    required this.cards,
    required this.pairsCount,
  });
}
```

## Data Flow

### Starting Session
```
User Action → start(level)
    ↓
generateStages(level)  [virtual method]
    ↓
Create List<GameStage>
    ↓
currentStageIndex = 0
    ↓
notifyListeners()
    ↓
UI renders getCurrentStage()
```

### Player's Answer
```
User Action → nextStage(result)
    ↓
Validation (isFinished?)
    ↓
Update completedCount (if not skipped)
    ↓
Check shouldFinish() [virtual]
    ↓
If not finished:
    currentStage++
    ↓
notifyListeners()
    ↓
UI renders new stage
```

### Skipping (Skip)
```
User Action → skipCurrentStage()
    ↓
canSkipStage(currentType)? [virtual]
    ↓
If YES:
    nextStage(StageResult(skipped: true))
    ↓
If NO:
    throw Exception
```

## File Structure
```
game_logic/
    round_managers/ - session managers
        game_session_manager.dart - abstract base class (extends ChangeNotifier)
        practice_session_manager.dart - practice mode implementation
        exam_session_manager.dart - exam mode implementation
    stages/ - stage data models
        stage_data.dart - abstract base class + implementations (MultipleChoiceData, TypedData, PairsData)
        game_stage.dart - GameStage model
        stage_type.dart - StageType enum
models/
    level/
        stage_result.dart - StageResult model
```