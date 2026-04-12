# Architecture for Educational Game App - Teaching Kids Multiplication

## Core Architecture Overview:
1. Flutter + Flame (Client Layer) - for building the game interface and handling user interactions.
2. Firebase (Services Layer) - for backend services including authentication, data storage, and analytics
3. Optional Services:
    - Cloud Functions - for server-side logic and report generation
    - Firebase Cloud Messaging - for sending notifications to parents about their child's progress

---

# CURRENT IMPLEMENTATION

## Firebase Authentication
**Status:** Service implemented, No UI (not actively used)
- UID: unique identifier
- Email: user email address
- Password: [encrypted by Firebase]
- Created timestamp
- Last login timestamp

*Firebase completely manages this data. AuthService exists but no login/register UI implemented.*

---

## Firestore Collections (Currently Implemented)

### 1. **`users/{uid}`** Collection
**Created by:** `onUserCreate` Cloud Function (triggered on user registration)  
**Status:** Cloud Function implemented, Never actually created (no auth UI)

**Document structure:**
```json
{
  "profile": {
    "displayName": "string",
    "email": "string", 
    "age": number,
    "createdAt": timestamp
  },
  "stats": {
    "totalGamesPlayed": 0,
    "totalPoints": 0,
    "currentStreak": 0,
    "lastPlayedAt": null
  },
  "settings": {}
}
```

**Cloud Function:** `onResultsWrite` updates stats when new results are written (also implemented but not used)

---

### 2. **`user_results/{sessionId}`** Collection
**Created by:** ResultsService in app (after game session)  
**Status:** Service implemented, Never called by game logic

**Document structure:**
```json
{
  "uid": "string",
  "sessionId": "string",
  "timestamp": timestamp,
  "stageResults": array,
  "score": number,
  "gameType": "string"
}
```

**Security:** Immutable after creation, only owner can read/write

---

### 3. **`game_progress/{sessionId}`** Collection
**Created by:** ProgressService in app (during gameplay)  
**Status:** Service implemented, Never called by game logic

**Document structure:**
```json
{
  "uid": "string",
  "gameId": "string",
  "sessionId": "string",
  "completedCount": number,
  "totalCount": number,
  "lastUpdated": timestamp
}
```

**Purpose:** Allows resuming gameplay after disconnection

---

## Current Database Tree Structure
```
Firestore Database
│
├── users/                          [Cloud Function creates, never used]
│   └── {uid}/
│       ├── profile: { displayName, email, age, createdAt }
│       ├── stats: { totalGamesPlayed, totalPoints, currentStreak, lastPlayedAt }
│       └── settings: { }
│
├── user_results/                   [Service exists, never called]
│   └── {sessionId}/
│       ├── uid
│       ├── sessionId
│       ├── timestamp
│       ├── stageResults
│       ├── score
│       └── gameType
│
└── game_progress/                  [Service exists, never called]
    └── {sessionId}/
        ├── uid
        ├── gameId
        ├── sessionId
        ├── completedCount
        ├── totalCount
        └── lastUpdated
```

---

## Current Data Flow (Actual Implementation)

**Reality:** Game runs entirely offline using Hive (LocalSaves) with hardcoded userId "user1"

```
1. App starts
   → No authentication
   → LocalSaves creates user "user1" in Hive if not exists

2. Show level selection screen
   → Read from Hive: LocalSaves.getLevel()
   → Levels are hardcoded and generated on first run
   → No Firebase interaction

3. User plays a level
   → Game generates questions locally
   → User plays...

4. Game ends
   → Save results to Hive only (LocalSaves.saveUser)
   → NO Firebase writes (ResultsService not called)
   → NO synchronization

5. Show results screen
   → Read from Hive: LocalSaves.getUser()
   → Display local progress only
```

**Note:** All Firebase services exist but are disconnected from game logic. Everything is stored locally only.

---
---

# TO BE IMPLEMENTED

## Missing Firestore Collections

### 1. **`levels/{levelId}`** Collection
**Status:** Not implemented (no service, no data)  
**Current workaround:** Levels hardcoded locally in Hive

**Planned structure:**
```json
{
  "levelId": "multiply-by-2",
  "levelNumber": 2,
  "name": "Multiply by 2",
  "description": "Learn multiplication by 2",
  "unlockRequirements": {
    "minPoints": 0,
    "previousLevelId": "multiply-by-1" 
  },
  "rewards": {
    "points": 100
  },
  "isRevision": false
}
```

**Example documents:**
- `levels/multiply-by-2`
- `levels/revision-by-2`
- `levels/multiply-by-3`
- etc.

**Security:** Public read, server-only write

---

### 2. **`leaderboards`** Collection
**Status:** Not implemented (no service, no UI)  
**Current state:** Placeholder screen showing "Leaderboard" text only

**Planned structure:**

**Global leaderboard:** `leaderboards/global`
```json
{
  "entries": [
    {
      "playerId": "uid",
      "playerName": "string",
      "streak": number,
      "dateAchieved": timestamp
    }
  ],
  "lastUpdated": timestamp
}
```

**Per-level leaderboards:** `leaderboards/level_{levelId}`
```json
{
  "entries": [
    {
      "playerId": "uid",
      "playerName": "string", 
      "bestScore": number,
      "bestTime": number,
      "dateAchieved": timestamp
    }
  ],
  "lastUpdated": timestamp
}
```

**Security:** Public read, server-only write (Cloud Function updates)

---

### 3. **`users/{uid}/levelProgress/{levelId}`** Subcollection
**Status:** Not implemented  
**Current workaround:** Stored locally in Hive only

**Planned structure:**
```json
{
  "levelId": "multiply-by-2",
  "bestScore": number,
  "bestTimeSeconds": number,
  "attempts": number,
  "completed": boolean,
  "firstCompletedAt": timestamp,
  "lastPlayedAt": timestamp
}
```

**Security:** Only owner can read/write

---

## Target Database Tree Structure (Full Implementation)
```
Firestore Database
│
├── users/
│   └── {uid}/
│       ├── profile: { displayName, email, age, createdAt }
│       ├── stats: { totalGamesPlayed, totalPoints, currentStreak, lastPlayedAt }
│       ├── settings: { }
│       └── (subcollection) levelProgress/
│           ├── multiply-by-2/
│           │   ├── levelId, bestScore, bestTimeSeconds
│           │   ├── attempts, completed
│           │   └── firstCompletedAt, lastPlayedAt
│           ├── multiply-by-3/
│           └── ...
│
├── user_results/
│   └── {sessionId}/
│       └── [session data - immutable]
│
├── game_progress/
│   └── {sessionId}/
│       └── [progress data for resuming]
│
├── levels/                          [TO IMPLEMENT]
│   ├── multiply-by-2/
│   ├── revision-by-2/
│   ├── multiply-by-3/
│   └── ...
│
└── leaderboards/                    [TO IMPLEMENT]
    ├── global/
    └── level_{levelId}/
```

---

## Target Data Flow (After Full Implementation)

```
1. User creates account
   → Firebase Auth creates UID
   → onUserCreate Cloud Function creates users/{uid} document

2. User logs in
   → Firebase Auth verification
   → Read: users/{uid}
   → App transitions from local storage to authenticated mode

3. Show level selection screen  
   → Read: levels/* (all level configs from Firestore)
   → Read: users/{uid}/levelProgress/* (user's progress)
   → Display unlocked/locked levels

4. User plays Level 2 (multiply-by-2)
   → Read: levels/multiply-by-2 (get level config)
   → Generate questions based on level config
   → Save progress: game_progress/{sessionId} (during play)

5. Game ends
   → Write: user_results/{sessionId} (immutable result)
   → onResultsWrite Cloud Function updates users/{uid}/stats
   → Write: users/{uid}/levelProgress/multiply-by-2
   → Cloud Function updates leaderboards (if high score)

6. Show results screen
   → Read: users/{uid}/levelProgress/multiply-by-2
   → Read: leaderboards/level_multiply-by-2
   → Display score, rank, and achievements

7. Offline sync
   → Queue writes locally when offline
   → SyncService uploads to Firestore when online
```