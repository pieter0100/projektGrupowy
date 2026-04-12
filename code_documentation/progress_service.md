# ProgressService - Detailed Documentation

`ProgressService` provides API for saving and reading user progress in games, supporting offline-first logic and batch synchronization to Firestore.

## Features
- Save user progress locally (Hive)
- Enqueue progress for periodic and event-based sync
- Get progress for a user and game
- Integrates with OfflineStore and SyncService

## API

### Methods

#### `Future<void> saveProgress(GameProgress progress)`
Saves user progress locally and enqueues it for synchronization.
- **Parameters:**
	- `progress`: GameProgress object to save

#### `Future<GameProgress?> getProgress(String uid, String gameId)`
Gets progress for a user and specific game.
- **Parameters:**
	- `uid`: User ID
	- `gameId`: Game identifier
- **Returns:**
	- GameProgress object or null if not found

## Usage Example
```dart
final progressService = ProgressService(offlineStore, syncService);

// Save progress
await progressService.saveProgress(gameProgress);

// Get progress
final progress = await progressService.getProgress('user1', 'gameA');
```

## Notes
- Progress is saved locally with sync_pending flag for offline-first support.
- Synchronization is handled by SyncService (batch write, retry/backoff).
- Last-write-wins logic is applied using lastUpdated field.
