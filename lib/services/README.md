# Services

This directory contains services responsible for generating questions, cards, and managing results/progress for educational games. These components are used by various game modules to deliver educational content and track user achievements.

## File Structure

### `question_provider.dart`
Question provider for all types of mini-games. The class contains static methods to generate multiplication table questions in three formats: questions for matching in pairs, multiple-choice questions, and questions requiring typed answers.
Generates questions with random multiplication combinations for a given level.
[Detailed description](../../code_documentation/question_provider_documentation.md)

### `card_generator.dart`
Card generator for the matching game. Based on a provided set of questions, it creates a deck of cards where each pair consists of an operation and its result. Cards are generated with unique identifiers and shuffled in random order.
Responsible for the physical representation of questions as a set of cards with pair identifiers, enabling the game mechanic of finding matching cards.

### `pairs_game_engine.dart`
Game engine for the matching pairs mini-game. Manages card selection, pair matching logic, and game state tracking. Detects game completion and triggers callbacks with the final `StageResult`.
Handles the core gameplay mechanics: validating selections, comparing pair identifiers, tracking progress, and generating results for integration with the session manager.
[Detailed description](../../code_documentation/pairs_game_engine_documentation.md)

### `typed_game_engine.dart`
Game engine for the typed answer mini-game. Players answer mathematical questions by typing their response. Handles answer normalization (case-insensitive, whitespace trimmed) and exact matching against the correct answer.
Supports skip functionality (when allowed by session manager) and generates `StageResult` for integration with session managers. Validates submission state to prevent illegal operations (e.g., submitting after skip).
[Detailed description](../../code_documentation/typed_game_engine_documentation.md)

### `mc_game_engine.dart`
Game engine for the multiple choice mini-game. Players select one of four options to answer multiplication questions. Validates selections, prevents duplicate answers, and generates `StageResult` based on correctness.
Handles option shuffling, answer verification, and result generation for integration with session managers. Enforces valid state transitions to prevent illegal operations (e.g., selecting twice).
[Detailed description](../../code_documentation/mc_game_engine_documentation.md)

### `auth_service.dart`
Provides authentication and user management using Firebase Authentication and Firestore.
- Register, sign in, sign out, password reset
- Creates user profile documents in Firestore
[Detailed description](../../code_documentation/auth_service.md)

### `results_service.dart`
API for saving and reading game results. Handles local storage and enqueuing results for synchronization.
[Detailed documentation](../../code_documentation/results_service.md)

### `progress_service.dart`
API for saving and reading user progress in games. Handles local storage and enqueuing progress for synchronization.
[Detailed documentation](../../code_documentation/progress_service.md)

### `offline_store.dart`
Local Hive storage for results and progress. Stores records with sync_pending flag and supports deduplication.
[Detailed documentation](../../code_documentation/offline_store.md)

### `sync_service.dart`
Service for synchronizing results and progress to Firestore. Manages sync queue, batch writes, retry/backoff, and error logging.
[Detailed documentation](../../code_documentation/sync_service.md)

#### Dependencies
```
Game Engines / Round Managers
            ↓
ResultsService / ProgressService
            ↓
    OfflineStore
            ↓
    SyncService
            ↓
    Firestore DB
```