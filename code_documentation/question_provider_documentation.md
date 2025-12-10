# QuestionProvider Documentation

## Overview

`QuestionProvider` is a class responsible for generating multiplication-based questions in three different formats for various educational game modes. It serves as the central question generation engine for the application, ensuring consistent and varied question generation across all mini-games.

## Class Structure

### Question Model Classes

#### `QuestionsPairs`
Represents a set of multiplication pairs for the matching card game.

**Properties:**
- `typeOfMultiplication` (int): The multiplication table level (1-10)
- `multipliers` (List<int>): List of unique multipliers to use (e.g., [3, 7, 2])

**Example:**
```dart
QuestionsPairs(
  typeOfMultiplication: 5,
  multipliers: [2, 7, 9]  // Will generate 5×2, 5×7, 5×9 pairs
)
```

#### `QuestionMC` (Multiple Choice)
Represents a multiple-choice question with four options.

**Properties:**
- `prompt` (String): The question text displayed to the user (e.g., "5 × 7 =")
- `options` (List<String>): Four answer options as strings
- `correctIndex` (int): The index (0-3) of the correct answer in the options list

**Example:**
```dart
QuestionMC(
  prompt: "5 × 7 =",
  options: ["45", "35", "10", "15"],
  correctIndex: 1  // "35" is the correct answer
)
```

#### `QuestionTyped`
Represents a question where the user must type the answer.

**Properties:**
- `prompt` (String): The question text (e.g., "5 × 7 =")
- `correctAnswer` (String): The correct answer as a string

**Example:**
```dart
QuestionTyped(
  prompt: "5 × 7 =",
  correctAnswer: "35"
)
```

---

## Methods

### 1. `getPairsQuestions()`

**Purpose:** Generates a set of multiplication pairs for the matching card game.

**Signature:**
```dart
static QuestionsPairs getPairsQuestions({
  required int level,
  int pairsAmount = 3,
})
```

**Parameters:**
- `level` (int): The difficulty level (1-10). Maps directly to the multiplication table (e.g., level 5 = 5×table)
- `pairsAmount` (int): Number of multiplication pairs to generate. Default is 3.

**How it works:**
1. Converts the level to a multiplication type using `_levelToType()`
2. Generates random unique multipliers using `_randomUniqueNumbers()`
3. Returns a `QuestionsPairs` object containing the type and multipliers

**Example:**
```dart
final pairs = QuestionProvider.getPairsQuestions(level: 5, pairsAmount: 3);
// Returns: QuestionsPairs(typeOfMultiplication: 5, multipliers: [2, 8, 4])
// This will create pairs: 5×2=10, 5×8=40, 5×4=20
```

**Use case:** Called by `RoundManager` when initializing a practice round to generate card pairs for the matching game.

---

### 2. `getMcQuestion()`

**Purpose:** Generates a random multiple-choice multiplication question.

**Signature:**
```dart
static QuestionMC getMcQuestion({required int level})
```

**Parameters:**
- `level` (int): The difficulty level (1-10)

**How it works:**
1. Converts level to multiplication type using `_levelToType()`
2. Generates a random multiplier `b` from 1-10
3. Calculates the correct answer: `a × b`
4. Creates the question prompt: `"a × b ="`
5. Generates 3 wrong answers:
   - Randomly picks numbers 1-10 (excluding `b`)
   - Multiplies them by `a`
   - Ensures all 4 options are unique
6. Shuffles the options randomly
7. Records the correct answer's index after shuffling

**Example walkthrough (level: 5):**
```
1. type = 5, a = 5
2. b = Random() → 7
3. answer = 5 × 7 = 35
4. prompt = "5 × 7 ="
5. Generate wrong answers:
   - option 3: 5 × 3 = 15
   - option 9: 5 × 9 = 45
   - option 2: 5 × 2 = 10
6. Shuffle: [45, 35, 10, 15]
7. correctIndex = 1 (position of 35)

Result:
QuestionMC(
  prompt: "5 × 7 =",
  options: ["45", "35", "10", "15"],
  correctIndex: 1
)
```

**Key feature:** Every call generates a new random question, ensuring variety even within the same level.

---

### 3. `getTypedQuestion()`

**Purpose:** Generates a question where the user must type the correct answer.

**Signature:**
```dart
static QuestionTyped getTypedQuestion({required int level})
```

**Parameters:**
- `level` (int): The difficulty level (1-10)

**How it works:**
1. Converts level to multiplication type using `_levelToType()`
2. Generates a random multiplier `b` from 1-10
3. Creates the question prompt: `"type × b ="`
4. Calculates the correct answer: `type × b`
5. Returns a `QuestionTyped` object with both

**Example (level: 5):**
```
type = 5
b = Random() → 7
prompt = "5 × 7 ="
correctAnswer = "35"

Result:
QuestionTyped(
  prompt: "5 × 7 =",
  correctAnswer: "35"
)
```

---

## Helper Methods

### `_levelToType()`

**Purpose:** Converts a game level to a multiplication table type.

**Signature:**
```dart
static int _levelToType(int level)
```

**Logic:**
- If level ≤ 0, returns 1
- Clamps level to range 1-10

**Examples:**
```dart
_levelToType(5)   → 5
_levelToType(0)   → 1
_levelToType(-3)  → 1
_levelToType(15)  → 10 (clamped)
```

---

### `_randomUniqueNumbers()`

**Purpose:** Generates a set of unique random numbers within a specified range.

**Signature:**
```dart
static List<int> _randomUniqueNumbers({
  required int count,
  required int maxInclusive,
})
```

**Parameters:**
- `count` (int): How many unique numbers to generate
- `maxInclusive` (int): The maximum value (inclusive), minimum is always 1

**How it works:**
1. Creates an empty set to track unique numbers
2. Continuously generates random numbers 1 to `maxInclusive`
3. Adds each number to the set (sets automatically prevent duplicates)
4. Stops when the set reaches the desired count
5. Returns the set as a list

**Example:**
```dart
_randomUniqueNumbers(count: 3, maxInclusive: 10)
// Possible output: [4, 9, 2]
// Each number is guaranteed to be unique and in range 1-10
```

**Use case:** Used by `getPairsQuestions()` to generate unique multipliers for card pairs.

---

## Data Flow Diagram

```
User requests question for Level 5
         ↓
QuestionProvider.getMcQuestion(level: 5)
         ↓
_levelToType(5) → 5
Generate random b (1-10) → 7
Calculate answer: 5 × 7 = 35
Generate 3 wrong options using random multipliers
Shuffle all 4 options
Find correctIndex in shuffled list
         ↓
Return QuestionMC object
```

---

## Integration with Game Modules

### Practice Mode (RoundManager)
```dart
// In RoundManager constructor
final questions = QuestionProvider.getPairsQuestions(
  level: typeOfMultiplication,
  pairsAmount: 3
);
final cardGenerator = CardGenerator(questions: questions);
```

Uses `getPairsQuestions()` to get pairs, then passes them to `CardGenerator` for the matching game.

### Quiz/MC Game
```dart
final question = QuestionProvider.getMcQuestion(level: 5);
// Display question.prompt with question.options
// Check if userAnswer == question.options[question.correctIndex]
```

### Typing Game
```dart
final question = QuestionProvider.getTypedQuestion(level: 5);
// Display question.prompt
// Check if userInput == question.correctAnswer
```

## Example Usage Scenarios

**Scenario 1: New Practice Round**
```dart
// User enters practice mode for level 5
final pairs = QuestionProvider.getPairsQuestions(level: 5, pairsAmount: 3);
// Returns 3 random pairs like: 5×2, 5×7, 5×9
```

**Scenario 2: Multiple Choice Question**
```dart
// User encounters MC question
final mcQ = QuestionProvider.getMcQuestion(level: 5);
// Display: "5 × 8 =" with 4 random options
```

**Scenario 3: Typing Question**
```dart
// User encounters typing question
final typedQ = QuestionProvider.getTypedQuestion(level: 5);
// Display: "5 × 6 =" and wait for user input
```