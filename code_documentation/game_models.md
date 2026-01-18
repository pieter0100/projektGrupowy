# Game Models - Detailed Documentation

## GameResult
Represents the result of a full game session for a user.
- **sessionId**: Unique session identifier for deduplication and sync
- **uid**: User ID
- **timestamp**: Date and time of the session
- **stageResults**: List of StageResult objects (results for each stage/level)
- **score**: Total score for the session
- **gameType**: Type of game played (e.g., MC, Typed, Pairs)
- **syncPending**: Indicates if the result is pending synchronization (offline-first)

### Example
```dart
GameResult(
  sessionId: 'abc123',
  uid: 'user1',
  timestamp: DateTime.now(),
  stageResults: [StageResult(...)],
  score: 10,
  gameType: 'MC',
)
```

## GameProgress
Represents the user's progress in a game.
- **sessionId**: Unique session identifier
- **uid**: User ID
- **gameId**: Game identifier
- **completedCount**: Number of completed stages
- **totalCount**: Total number of stages in the game
- **lastUpdated**: Last update timestamp (for last-write-wins sync)
- **syncPending**: Indicates if the progress is pending synchronization

### Example
```dart
GameProgress(
  sessionId: 'abc123',
  uid: 'user1',
  gameId: 'gameA',
  completedCount: 5,
  totalCount: 10,
  lastUpdated: DateTime.now(),
)
```



## Relationships
- Each GameResult contains a list of StageResult objects, representing the outcome of each stage in the session.
- GameProgress tracks the overall progress for a user in a specific game.
- These models are used for offline-first storage, synchronization, and deduplication in Firestore.
