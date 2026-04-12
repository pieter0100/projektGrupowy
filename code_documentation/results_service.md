# ResultsService - Detailed Documentation

`ResultsService` provides API for saving and reading game results, supporting offline-first logic and batch synchronization to Firestore.

## Features
- Save game results locally (Hive)
- Enqueue results for periodic and event-based sync
- List user results with limit and paging
- Integrates with OfflineStore and SyncService

## API

### Methods

#### `Future<void> saveResult(GameResult result)`
Saves a game result locally and enqueues it for synchronization.
- **Parameters:**
	- `result`: GameResult object to save

#### `Future<List<GameResult>> listUserResults(String uid, {int? limit, int? paging})`
Lists results for a user, with optional limit and paging.
- **Parameters:**
	- `uid`: User ID
	- `limit`: Optional max number of results
	- `paging`: Optional paging parameter
- **Returns:**
	- List of GameResult objects

## Usage Example
```dart
final resultsService = ResultsService(offlineStore, syncService);

// Save a result
await resultsService.saveResult(gameResult);

// List user results
final results = await resultsService.listUserResults('user1', limit: 10);
```

## Notes
- Results are saved locally with sync_pending flag for offline-first support.
- Synchronization is handled by SyncService (batch write, retry/backoff).
- Deduplication by sessionId is supported.
