# Round Managers Directory

Game session management system that orchestrates different game modes (Practice and Exam) with support for multiple stage types (Multiple Choice, Typed, and Pairs).

## File Structure

### `game_session_manager.dart`
Abstract base class defining shared API and logic for all game modes. Extends `ChangeNotifier` for reactive UI updates. Manages session state, stage progression, and completion tracking.

[Detailed documentation](../../../code_documentation/game_session_manager.md)

### `practice_session_manager.dart`
Implementation of Practice mode game session. Features 6 stages with random type selection using anti-series rule (never 3 same in a row). Skip allowed only for Typed stages.

[Detailed documentation](../../../code_documentation/practice_session_manager.md)

### `exam_session_manager.dart`
Implementation of Exam mode game session. Features 10 Typed stages with accuracy tracking. Skip is forbidden. Calculates and provides accuracy metrics.

[Detailed documentation](../../../code_documentation/exam_session_manager.md)

## System Architecture

```
GameSessionManager (abstract)
       ↓
    ┌──────────────────┐
    ↓                  ↓
PracticeSessionManager  ExamSessionManager
```

All session managers extend `ChangeNotifier` for reactive UI updates.

## Data Models

Core data models used across the system:
- `StageType` - Enum defining stage types (MC, Typed, Pairs)
- `StageResult` - Result data for a completed stage
- `GameStage` - Combines stage type with stage-specific data
- `StageData` - Abstract base with concrete implementations for each stage type

[Detailed documentation](code_documentation/data_models.md)

## Related Components

### Validators (`lib/game_logic/validators/`)
- `MCValidator` - Validates Multiple Choice answers
- `TypedValidator` - Validates Typed answers and parses input
- `PairsRoundManager` - Manages Pairs matching game logic

### Stage Data (`lib/game_logic/stages/`)
- `stage_type.dart` - StageType enum
- `stage_data.dart` - StageData classes (MC, Typed, Pairs)
- `game_stage.dart` - GameStage model

### Models (`lib/models/level/`)
- `stage_result.dart` - StageResult model
- `level.dart` - LevelInfo model
