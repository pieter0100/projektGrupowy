# Pairs Game Engine

## Overview

The Pairs Game is a memory matching card game where players find pairs of cards with matching values. The game logic has been extracted into `PairsGameEngine` for better separation of concerns.

## Architecture

```
PairsGameEngine (services/)
    ↓
    Uses: CardGenerator + QuestionProvider
    Returns: StageResult
    Callback: onComplete(StageResult)
```

## Card Generation Logic

The `CardGenerator` class is responsible for generating a deck of cards for the game. Each card has:
- Unique identifier (`id`)
- Pair identifier (`pairId`) - links matching cards
- Value (`value`) - display text (e.g., "2 x 8" or "16")
- Matched status (`isMatched`)

### Example Usage

```dart
// PairsGameEngine internally creates CardGenerator
final engine = PairsGameEngine(
  pairsAmount: 3,
  typeOfMultiplication: 2,
  onComplete: (result) {
    print('Game complete: ${result.isCorrect}');
  }
);

// Access the generated deck
engine.currentDeck.forEach((card) {
  print('Card: ${card.value}, matched: ${card.isMatched}');
});
```

### Example Card Output

```
Card id: 80a92f74-2f75-4b6f-9082-5dac7be436af
  pairId: e8675a9a-d085-4756-9989-dae0f53a9c5f
  value: 2 x 8
  isMatched: false

Card id: e8675a9a-d085-4756-9989-dae0f53a9c5f
  pairId: 80a92f74-2f75-4b6f-9082-5dac7be436af
  value: 16
  isMatched: false
```

## PairsGameEngine Logic

### Core Responsibilities

1. **Card Selection Management**
   - Tracks selected cards (max 2 at a time)
   - Validates selections (no duplicates, no matched cards)

2. **Pair Matching**
   - Compares `pairIds` of selected cards
   - Card 1 id == Card 2 pairId → Match found
   - Marks matched cards with `isMatched = true`

3. **Game State Tracking**
   - Counts matched pairs
   - Tracks attempts
   - Calculates progress (0.0 - 1.0)
   - Detects completion (all pairs matched)

4. **Result Generation**
   - Returns `StageResult` when game completes
   - Includes metadata: attempts, matched pairs count

### Game Flow

```
1. Player selects first card → added to selectedCards
   ↓
2. Player selects second card → triggers checkSelectedCards()
   ↓
3a. Cards match (pairIds match)
    - Mark both as isMatched = true
    - Increment matchedPairs
    - Return SelectionStatus.matchFound
    ↓
3b. Cards don't match (pairIds don't match)
    - Mark both as isFailed = true
    - Return SelectionStatus.matchFailed
    ↓
3c. Invalid selection (same card, already matched, etc.)
    - Clear selection
    - Return SelectionStatus.cannotSelect
    ↓
4. If all pairs matched (progress >= 1.0)
    - Call onComplete() callback with StageResult
    - Game finished
```

### Selection Status Enum

```dart
enum SelectionStatus {
  matchFound,      // Two cards with matching pairIds
  matchFailed,     // Two cards that don't match
  cannotSelect,    // Invalid selection (duplicate, matched, etc.)
}
```

### Public API

```dart
// Card selection - returns SelectionStatus or null
SelectionStatus? onCardSelected(CardItem card);

// Query game state
bool isGameCompleted();
double getProgress();          // 0.0 to 1.0
Map<String, dynamic> getGameState();

// Reset for replay
void resetGame();

// Logging
void logGameState();
void logMessage(String message);
```

### Example Usage

```dart
final engine = PairsGameEngine(
  pairsAmount: 3,
  typeOfMultiplication: 2,
  onComplete: (result) {
    print('Completed with ${result.userAnswer['attempts']} attempts');
  },
);

// Game loop
void onCardTap(CardItem card) {
  final status = engine.onCardSelected(card);
  
  if (status == SelectionStatus.matchFound) {
    print('Match found!');
  } else if (status == SelectionStatus.matchFailed) {
    print('No match, try again');
  }
  
  // Update UI with new game state
  updateUI(engine.getGameState());
}

// When game finishes, onComplete is automatically called
```

## Integration with GameSessionManager

`PairsGameEngine` is used as a mini-game engine within `PracticeSessionManager` or `ExamSessionManager`:

```
PracticeSessionManager
    ↓ (when currentType == StageType.pairs)
    ↓
Pairs_Screen
    ↓
PairsGameEngine
    ↓ (onComplete callback)
    ↓
manager.nextStage(result)
```

## Testing

See `test/services/pairs_game_engine_test.dart` for comprehensive unit tests covering:
- Card selection logic
- Pair matching algorithm
- Game completion detection
- State management
- Edge cases (duplicate selection, already matched cards, etc.)