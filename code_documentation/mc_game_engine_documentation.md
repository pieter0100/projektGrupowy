# MC Game Engine (Multiple Choice)

## Overview

The Multiple Choice Game is a mini-game where players answer mathematical questions by selecting one of four options. The engine validates selections and generates results for integration with session managers.

## Architecture

```
MCGameEngine (services/)
    ↓
    Uses: QuestionProvider
    Returns: StageResult
    Callback: onComplete(StageResult)
```

## Question Generation

Questions are generated using `QuestionProvider.getMcQuestion()`:

```dart
// Example: Level 2
final question = QuestionProvider.getMcQuestion(level: 2);
// Question: "2 × 5 =", Options: ["10", "12", "8", "14"], Correct: index 0

final question = QuestionProvider.getMcQuestion(level: 5);
// Question: "5 × 7 =", Options: ["35", "30", "40", "25"], Correct: index varies
```

### Question Structure

```dart
class QuestionMC {
  final String prompt;        // e.g., "2 × 5 ="
  final List<String> options; // 4 options, shuffled
  final int correctIndex;     // Index of correct answer (0-3)
}
```

### Option Characteristics

- **Count**: Always 4 options
- **Type**: All numeric strings (results of different multiplications)
- **Order**: Randomly shuffled (correct answer can be at any index)
- **Uniqueness**: All options are different

## MCGameEngine Logic

### Core Responsibilities

1. **Question Management**
   - Initialize with a level
   - Provide question prompt and options

2. **Selection Validation**
   - Validate option index (0-3)
   - Prevent duplicate selections
   - Throw error for invalid indices

3. **Answer Verification**
   - Compare selected index with correct index
   - Generate result with correctness flag

4. **Result Generation**
   - Returns `StageResult` with:
     - `isCorrect`: true/false
     - `userAnswer`: map with selectedIndex and selectedAnswer

### Game Flow

```
1. Initialize engine with level
   engine.initialize(level)
   ↓
2. Get question and present to user
   prompt = engine.question.prompt
   options = engine.question.options (displayed as 4 buttons)
   ↓
3. User selects option by clicking button (index 0-3)
   engine.selectOption(selectedIndex)
   ↓
   - Validate index (0-3)
   - Check if answer already selected
   - Compare with correct index
   - Generate StageResult(isCorrect: bool)
   - Call onComplete(result)
```

### Public API

```dart
// Initialize engine with a level
void initialize(int level);

// Get current question
QuestionMC get question;

// Get index of correct answer
int get correctIndex;

// Get correct answer text
String get correctAnswer;

// Select an option by index (0-3)
void selectOption(int optionIndex);

// Check if answer was selected
bool get answerSelected;

// Get selected answer text (or null)
String? get selectedAnswer;

// Query game state
Map<String, dynamic> getGameState();

// Logging
void logGameState();
void logMessage(String message);
```

### State Validation

The engine enforces valid state transitions:

```dart
// ✅ Valid: initialize → select
engine.initialize(2);
engine.selectOption(0);

// ❌ Invalid: select twice
engine.initialize(2);
engine.selectOption(0);
engine.selectOption(1); // throws StateError

// ❌ Invalid: select invalid index
engine.initialize(2);
engine.selectOption(4); // throws RangeError
engine.selectOption(-1); // throws RangeError
```

### Example Usage

```dart
final engine = MCGameEngine(
  onComplete: (result) {
    print('Correct: ${result.isCorrect}');
    print('Selected: ${result.userAnswer['selectedAnswer']}');
  },
);

// Initialize with level
engine.initialize(3); // Level 3 → type 3

// Present question and options to user
print(engine.question.prompt);        // "3 × 7 ="
for (var i = 0; i < engine.question.options.length; i++) {
  print('$i. ${engine.question.options[i]}');
}

// User clicks option button (index 0-3)
void onOptionSelected(int index) {
  engine.selectOption(index);
  // onComplete callback fires automatically with result
}
```

### StageResult Structure

```dart
StageResult(
  isCorrect: true,
  skipped: false,
  userAnswer: {
    'selectedIndex': 0,
    'selectedAnswer': '21',  // 3 × 7 = 21
  },
)
```

## Integration with GameSessionManager

`MCGameEngine` is used as a mini-game engine within `PracticeSessionManager` or `ExamSessionManager`:

```
PracticeSessionManager or ExamSessionManager
    ↓ (when currentType == StageType.multipleChoice)
    ↓
MC_Screen
    ↓
MCGameEngine
    ↓ (onComplete callback)
    ↓
manager.nextStage(result)
```

## UI Integration

The MC_Screen widget should:

1. Display the question prompt
2. Display 4 buttons for each option
3. Handle option clicks → call `engine.selectOption(index)`
4. Visual feedback on selection (highlight correct/incorrect)
5. Disable buttons after selection

```dart
// Pseudo-code for MC_Screen
class MCScreen extends StatefulWidget {
  final MCGameEngine engine;
  final Function(StageResult) onComplete;
  
  @override
  build(context) {
    return Column(
      children: [
        Text(engine.question.prompt),
        ...List.generate(4, (index) {
          return ElevatedButton(
            onPressed: engine.answerSelected ? null : () {
              engine.selectOption(index);
            },
            child: Text(engine.question.options[index]),
          );
        }),
      ],
    );
  }
}
```

## Testing

See `test/services/mc_game_engine_test.dart` for comprehensive unit tests covering:
- Correct/incorrect answer detection
- Option selection validation
- State management (preventing duplicate selections)
- Edge cases (invalid indices)
- Question structure (4 options, all unique)
- Callback behavior
- Different levels generating different questions
