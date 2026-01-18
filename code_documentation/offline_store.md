# OfflineStore - Detailed Documentation

`OfflineStore` provides local Hive storage for results and progress, supporting offline-first logic and deduplication by session_id.

## Features
- Save results and progress locally with sync_pending flag
- Get records pending synchronization
- Mark records as synced after successful sync
- Deduplication by session_id/local_id

## API

### Methods

#### `Future<void> saveResult(GameResult result)`
Saves a game result locally with sync_pending flag.
- **Parameters:**
	- `result`: GameResult object to save

#### `Future<List<GameResult>> listUserResults(String uid, {int? limit, int? paging})`
Lists results for a user, optionally with limit and paging.
- **Parameters:**
	- `uid`: User ID
	- `limit`: Optional max number of results
	- `paging`: Optional paging parameter
- **Returns:**
	- List of GameResult objects

#### `Future<void> saveProgress(GameProgress progress)`
Saves user progress locally with sync_pending flag.
- **Parameters:**
	- `progress`: GameProgress object to save

#### `Future<GameProgress?> getProgress(String uid, String gameId)`
Gets the first progress record for a user and specific game.
- **Parameters:**
	- `uid`: User ID
	- `gameId`: Game identifier
- **Returns:**
	- GameProgress object or null if not found

#### `List<GameResult> getPendingResults()`
Gets all results pending synchronization.
- **Returns:**
	- List of GameResult objects

#### `List<GameProgress> getPendingProgress()`
Gets all progress records pending synchronization.
- **Returns:**
	- List of GameProgress objects

#### `Future<void> markResultSynced(String sessionId)`
Marks a result as synced after successful sync.
- **Parameters:**
	- `sessionId`: Session identifier

#### `Future<void> markProgressSynced(String sessionId)`
Marks a progress record as synced after successful sync.
- **Parameters:**
	- `sessionId`: Session identifier

## Usage Example
```dart
final offlineStore = OfflineStore(resultsBox, progressBox);

// Save result
await offlineStore.saveResult(gameResult);

// List user results
final userResults = await offlineStore.listUserResults('user1', limit: 10);

// Save progress
await offlineStore.saveProgress(gameProgress);

// Get progress for user and game
final progress = await offlineStore.getProgress('user1', 'gameA');

// Get pending results
final pendingResults = offlineStore.getPendingResults();

// Get pending progress
final pendingProgress = offlineStore.getPendingProgress();

// Mark result as synced
await offlineStore.markResultSynced('session123');

// Mark progress as synced
await offlineStore.markProgressSynced('session123');
```

## Notes
- Used by ResultsService, ProgressService, and SyncService for offline-first logic.
- Ensures no data loss when offline; records are synced when online.
