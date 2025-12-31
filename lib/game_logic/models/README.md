
# Game Models Directory

Models for storing and synchronizing game results and user progress in offline-first architecture. Used by services for local Hive storage and Firestore sync.

## File Structure

### `game_result.dart`
Defines the GameResult model, representing the result of a full game session for a user. Aggregates all StageResult objects for the session, user ID, session ID, score, game type, and sync status.

[Detailed documentation](../../code_documentation/game_models.md)

### `game_progress.dart`
Defines the GameProgress model, representing the user's progress in a specific game. Tracks completed stages, total stages, last update timestamp, and sync status.

[Detailed documentation](../../code_documentation/game_models.md)

### `stage_result.dart`
Defines the StageResult model, representing the result of a single stage/level in a game session. Stores correctness, skipped status, answer time, and user answer.

[Detailed documentation](../../code_documentation/data_models.md)

## System Architecture

```
GameResult
	↑
StageResult (multiple per GameResult)

GameProgress
```

GameResult aggregates StageResult objects for a session. GameProgress tracks overall progress for a user in a game.

## Related Components

### Services (`lib/services/`)
- `results_service.dart` - API for saving and reading results
- `progress_service.dart` - API for saving and reading progress
- `offline_store.dart` - Local Hive storage for results and progress
- `sync_service.dart` - Sync queue and batch write to Firestore

### Models (`lib/models/level/`)
- `stage_result.dart` - StageResult model
- `level.dart` - LevelInfo model
