## Classes in Dart

### Needed methods
- **Constructor**
- **toJson()** - used to convert an object to a JSON representation
- **fromJson()** - used to create an object from a JSON representation
- **copyWith()** - used to create a copy of an object with some modified fields (direct changes to the original object are not allowed, immutability)
    ```dart
    class LevelProgress {
    final String levelId;  // 'final' means can't change
    final int highScore;
    final int attempts;
    
    LevelProgress({
        required this.levelId,
        required this.highScore,
        required this.attempts,
    });
    }

    // Usage:
    final progress = LevelProgress(
    levelId: 'level-1',
    highScore: 100,
    attempts: 3,
    );

    // ❌ This doesn't work - can't modify final fields!
    progress.highScore = 150; // ERROR!
    progress.attempts = 4;    // ERROR!

    // ❌ You'd have to create a whole new object manually:
    final updated = LevelProgress(
    levelId: progress.levelId,     // Copy old value
    highScore: 150,                // New value
    attempts: progress.attempts,   // Copy old value - OOPS, forgot to update!
    );
    // ✅ Instead, use copyWith to create a modified copy:\
    final updated = progress.copyWith(
    highScore: 150,  // Only specify fields to change
    );
    // Result: updated has levelId='level-1', highScore=150, attempts=3
    ```
### Optional methods
- **toString()** - used to provide a string representation of the object, useful for debugging
- **equals()** - used to compare two objects for equality
### Not needed methods
- **setter()**, **getter()** - Dart provides default getters and setters for class fields, so explicit definitions are not necessary unless custom behavior is required
- **hashCode()** - Dart automatically provides a hash code for objects, so explicit definitions are not necessary unless custom behavior is required
- **deconstructor()** - Dart does not have a built-in deconstructor method; resource cleanup is typically handled using other mechanisms such as the `dispose()` method in Flutter widgets
- **Garbage Collector** - Dart has an automatic garbage collector, so manual memory management is not required

----
# Database Structure

### 0. **Data stored by Firebase Authentication**
- UID: "abc123xyz789"                  
- Email: "student@example.com"
- Password: [encrypted]
- Created: 2025-10-24
- Last Login: 2025-10-25

*Able to read all user data, but cannot modify it. Firebase completely manages this data.*

### 1. **`users`** Collection
users/{userId}  ← One document per user, userId matches Firebase Auth UID

**Single document containing:**
- `profile` - object { displayName, age}
- `stats` - object { totalGamesPlayed, totalPoints, currentStreak, lastPlayedAt }

---

### 2. **`levels`** Collection

levels/{levelId}  ← One document per level (e.g., "multiply-by-2")

**Contains:**
- Level configuration { levelNumber, name, description }
- `unlockRequirements` - object { minPoints, previousLevelId }
- `rewards` - object { points }
- `isRevision` - boolean

**Example documents:**
- `levels/multiply-by-2`
- `levels/revision-by-2`

---

### 4. **`leaderboards`** Collection

leaderboards/global  ← Single document for global leaderboard
leaderboards/level_{levelId}  ← One document per level leaderboard

**Contains:**
- `entries[]` - array of:
   - `playerId` - reference to the player
   - `playerName` - name of the player
   - `streak` - current / biggest streak
   - `dateAchieved` - timestamp of when the score was achieved 
- `lastUpdated` - timestamp

---

## **Subcollections**

### 5. **`levelProgress`** Subcollection (under users)

users/{userId}/levelProgress/{levelId}  ← One document per level attempt

**Contains:**
- `levelId`
- `bestScore`, `bestTimeSeconds`
- `attempts` - number of times played
- `completed` - boolean
- `firstCompletedAt`, `lastPlayedAt`

---

## **Complete Tree Structure**
```
Firestore Database
│
├── users/
│   ├── {userId - created, managed and stored by Firebase Authentication}/
│   │   ├── profile: { }
│   │   ├── settings: { }
│   │   ├── stats: { }
│   │   └── (subcollection) levelProgress/
│   │       ├── multiply-by-2/
│   │       ├── multiply-by-3/
│   │       ├── revision-2-5/
│   │       └── ...
│   │
│   └── {anotherUserId}/
│       └── ...
│
├── levels/
│   ├── multiply-by-2/
│   ├── revision-by-2/
│   ├── multiply-by-3/
│   ├── revision-by-3/
│   ├── multiply-by-4/
│   ├── revision-by-4/
│   ├── multiply-by-5/
│   ├── revision-by-5/
│   └── ...
│
└── leaderboards/
    └── global/
```

## Storage Strategy

### Use Hive + Classes for:
- **users/** → `UserProfile`, `UserStats` (Hive boxes)
- **users/{userId}/levelProgress/** → `LevelProgress` (Hive box with composite keys)
- **levels/** → `LevelInfo` (Hive box)
- **leaderboards/global/** → `LeaderboardEntry` (Hive box)

### Why Both?
- **Classes** provide type safety, organization, and match Firebase structure
- **Hive** handles efficient storage and retrieval
### Data Flow

```
Your Object  →  Adapter.write()  →  Binary Data  →  Hive Storage
    ↑                                                      ↓
    └────────  Adapter.read()  ←─────────────────────────┘
```

### Hive adapter
- Hive dependency is added to `pubspec.yaml`. Before first use, run `flutter pub get` to generate adapter files.

- Hive stores data in binary format for efficiency but cannot directly store complex objects
- Each class needs a corresponding Hive adapter to serialize/deserialize the object to/from binary format for storage
- Adapters are generated using the `build_runner` package based on annotations in the class definitions (thats why we use `@HiveType` and `@HiveField`)

To generate adapters, run:
```dart 
dart run build_runner build
```

If the class structure changes, re-run the command to update the adapters accordingly

### Adapter Registration
- Before using Hive to store/retrieve objects, register the adapters with Hive
```dart
Hive.registerAdapter(ClassAdapter());
```

### Hive Box Operations
- Boxes are like tables in a database where you store objects of a specific type
- Open a box using:
```dart
  Box<Class> box = await Hive.openBox<Class>('boxName');
```
- Perform CRUD operations using:
  - `box.put(key, object)` - Store an object
  - `box.get(key)` - Retrieve an object
  - `box.delete(key)` - Delete an object
  - `box.values` - Get all objects in the box
