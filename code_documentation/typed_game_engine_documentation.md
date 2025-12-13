# Typed Game Engine

## Overview

The Typed Answer Game is a mini-game where players answer mathematical multiplication questions by typing their response. The engine handles answer validation, normalization, and result generation for integration with session managers.

## Architecture

```
TypedGameEngine (services/)
    ↓
    Uses: QuestionProvider
    Returns: StageResult
    Callback: onComplete(StageResult)
```

## Question Generation

Questions are generated using `QuestionProvider.getTypedQuestion()`:

```dart
// Example: Level 2
final question = QuestionProvider.getTypedQuestion(level: 2);
// Question: "2 × 5 =", Correct Answer: "10"

final question = QuestionProvider.getTypedQuestion(level: 5);
// Question: "5 × 7 =", Correct Answer: "35"
```

### Question Structure

```dart
class QuestionTyped {
  final String prompt;        // e.g., "2 × 5 ="
  final String correctAnswer; // e.g., "10"
}
```

## TypedGameEngine Logic

### Core Responsibilities

1. **Question Management**
   - Initialize with a level
   - Provide question prompt and correct answer

2. **Answer Normalization**
   - Trim whitespace: `"  10  "` → `"10"`
   - Lowercase conversion: `"10"` (consistent)
   - Handles both numeric and text answers

3. **Answer Validation**
   - Exact string comparison after normalization
   - `"10"` == `"10"` ✅
   - `"  10  "` == `"10"` ✅
   - `"10"` == `"11"` ❌
   - `""` == `"10"` ❌

4. **State Management**
   - Tracks user input
   - Prevents illegal state transitions (e.g., submit after skip)

5. **Result Generation**
   - Returns `StageResult` with correctness info
   - Supports skip functionality

### Game Flow

```
1. Initialize engine with level
   engine.initialize(level)
   ↓
2. Get question and present to user
   prompt = engine.question.prompt
   ↓
3a. User types and submits answer
   engine.submitAnswer(userInput)
   ↓
   - Normalize both inputs
   - Compare: normalized input == normalized correct answer
   - Generate StageResult(isCorrect: bool, skipped: false)
   - Call onComplete(result)
   ↓
3b. OR user clicks "Don't Know?"
   engine.skip()
   ↓
   - Generate StageResult.skipped()
   - Call onComplete(result)
```

### Answer Normalization Examples

```
Input: "10"           → Normalized: "10"       ✅
Input: "  10  "       → Normalized: "10"       ✅
Input: "10\n"         → Normalized: "10"       ✅
Input: "10  \t  "     → Normalized: "10"       ✅
Input: ""             → Normalized: ""         ❌ (empty)
Input: "   "          → Normalized: ""         ❌ (empty)
Input: "11"           → Normalized: "11"       ❌ (wrong)
```

### Public API

```dart
// Initialize engine with a level
void initialize(int level);

// Get current question
QuestionTyped get question;

// Get correct answer for current question
String get correctAnswer;

// Submit user's typed answer
void submitAnswer(String userInput);

// Skip the current question (if allowed by session manager)
void skip();

// Query game state
Map<String, dynamic> getGameState();

// Logging
void logGameState();
void logMessage(String message);
```

### State Validation

The engine enforces valid state transitions:

```dart
// ✅ Valid: initialize → submit
engine.initialize(2);
engine.submitAnswer("10");

// ✅ Valid: initialize → skip
engine.initialize(2);
engine.skip();

// ❌ Invalid: submit then skip
engine.initialize(2);
engine.submitAnswer("10");
engine.skip(); // throws StateError

// ❌ Invalid: skip then submit
engine.initialize(2);
engine.skip();
engine.submitAnswer("10"); // throws StateError
```

### Example Usage

```dart
final engine = TypedGameEngine(
  onComplete: (result) {
    print('Correct: ${result.isCorrect}');
    print('Answer: ${result.userAnswer}');
  },
);

// Initialize with level
engine.initialize(3); // Level 3 → type 3

// Present question to user
print(engine.question.prompt); // e.g., "3 × 7 ="

// User enters answer via TextField
void onSubmit(String userInput) {
  engine.submitAnswer(userInput);
  // onComplete callback fires automatically
}

// OR user clicks "Don't Know?"
void onSkip() {
  engine.skip();
  // onComplete callback fires with StageResult.skipped()
}
```

## Integration with GameSessionManager

`TypedGameEngine` is used as a mini-game engine within `PracticeSessionManager` or `ExamSessionManager`:

```
PracticeSessionManager or ExamSessionManager
    ↓ (when currentType == StageType.typed)
    ↓
Typed_Screen
    ↓
TypedGameEngine
    ↓ (onComplete callback with StageResult)
    ↓
manager.nextStage(result)
```

### Integration in PracticeSessionManager

In Practice mode, skip is **allowed**:

```dart
// In Typed_Screen widget
final manager = PracticeSessionManager();

engine = TypedGameEngine(
  onComplete: (result) {
    manager.nextStage(result);
    // If skipped, completedCount stays same
    // If submitted, completedCount++
  },
);

// Show "Don't Know?" button
ElevatedButton(
  onPressed: () {
    engine.skip();
    // onComplete fires with StageResult.skipped() + correctAnswer
    // UI can now display: "Correct answer: ${result.userAnswer['correctAnswer']}"
  },
  child: Text('Don\'t know?'),
)
```

### Integration in ExamSessionManager

In Exam mode, skip is **forbidden** - UI layer enforces this:

```dart
// In Typed_Screen widget - check BEFORE rendering
if (manager.canSkipStage()) {
  // Practice mode - show "Don't Know?" button
  ElevatedButton(
    onPressed: () => engine.skip(),
    child: Text('Don\'t know?'),
  );
} else {
  // Exam mode - DON'T show skip button
  // (currentType is Typed, and canSkipStage() = false for Exam)
  SizedBox.shrink(); // hidden
}
```

### Showing Correct Answer on Skip (Practice Mode Only)

The `TypedGameEngine` **does NOT** display anything - it only provides the data.
The **UI layer** is responsible for:

1. Checking if skip was allowed (check session manager's `canSkipStage()`)
2. Displaying the correct answer if allowed
3. Resetting UI state after a brief delay

```dart
// In Typed_Screen widget
void onSkip() {
  engine.skip();
  // onComplete callback receives StageResult with correctAnswer
}

// In onComplete callback
engine = TypedGameEngine(
  onComplete: (result) {
    if (result.skipped && manager.canSkipStage()) {
      // Show correct answer for 2 seconds
      final correctAnswer = result.userAnswer['correctAnswer'];
      showCorrectAnswerBanner(correctAnswer);
      
      Future.delayed(Duration(seconds: 2), () {
        manager.nextStage(result);
        // Navigate to next stage
      });
    } else {
      // Regular submission or skip not allowed
      manager.nextStage(result);
    }
  },
);
```

## Separation of Concerns

**TypedGameEngine is responsible for:**
- ✅ Generating questions
- ✅ Normalizing answers
- ✅ Validating answers
- ✅ Providing correct answer in StageResult
- ✅ Managing game state

**Typed_Screen UI is responsible for:**
- ✅ Displaying question and input field
- ✅ Checking `manager.canSkipStage()` to decide whether to show "Don't Know?" button
- ✅ Displaying correct answer when skipped (in Practice mode only)
- ✅ Visual feedback (correct/incorrect animation)
- ✅ State transitions

## Testing

See `test/services/typed_game_engine_test.dart` for comprehensive unit tests covering:
- Correct/incorrect answer detection
- Answer normalization (case, whitespace)
- Skip functionality
- State validation (preventing illegal transitions)
- Edge cases (empty input, whitespace-only input)
- Callback behavior
- Different levels generating different questions
