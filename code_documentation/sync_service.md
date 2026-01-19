# SyncService - Detailed Documentation

`SyncService` synchronizes results and progress to Firestore, managing sync queue, batch writes, retry/backoff, and error logging.

## Features
- Periodic and event-based sync (e.g., every 15 min, on connectivity change)
- Batch write to Firestore collections: user_results, game_progress
- Retry with exponential backoff
- Deduplication by session_id
- Error logging per item
- Sync only with active Firebase Auth session
- Stops immediately on sign out

## API

### Methods

#### `void start()`
Initiates periodic sync (e.g., every 15 min).


#### `Future<void> syncNow()`
Performs immediate sync (on connectivity change or app start).

## Usage Example
```dart
final syncService = SyncService(offlineStore, firestore);

// Start periodic sync
syncService.start();

// Immediate sync
await syncService.syncNow();
```

## Notes
- Sync is only performed with an active Firebase Auth session and in foreground.
- Stops immediately on sign out.
- Handles batch write, retry/backoff, deduplication, and error logging.
