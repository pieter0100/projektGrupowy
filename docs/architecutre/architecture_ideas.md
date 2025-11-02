# Architecture Ideas for Educational Game App - Teaching Kids Multiplication

## Core Architecture Overview:
1. Flutter + Flame (Client Layer) - for building the game interface and handling user interactions.
2. Firebase (Services Layer) - for backend services including authentication, data storage, and analytics
3. Optional Services:
    - Cloud Functions - for server-side logic and report generation
    - Firebase Cloud Messaging - for sending notifications to parents about their child's progress


----
# Firestore Database Structure

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
- `profile` - object { displayName, email, age, createdAt }
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
│
└── leaderboards/
    └── global/
```

---

## **Data Flow Example**
```
1. User creates account
   → Firebase Auth creates userId
   → Create document in users/{userId} with initial profile and stats
```
```
1. User logs in
   → Read: users/{userId}

2. Show level selection screen
   → Read: levels/* (all levels)
   → Read: users/{userId}/levelProgress/* (user's progress)

3. User plays Level 1 (multiply-by-2)
   → Read: levels/multiply-by-2
   → Game generates questions
   → User plays...

4. Game ends
   → Update: users/{userId} (increment stats)
   → Write: users/{userId}/levelProgress/multiply-by-2
   → Update: leaderboards/level_multiply-by-2 (if high score)

5. Show results screen
   → Read: users/{userId}/levelProgress/multiply-by-2 (show stars)
   → Read: leaderboards/level_multiply-by-2 (show ranking)
```


TODO:
- authetication (keeping passwords)
- normals levels diffrent modes mixed + revision after every level
- how to keep questions (server side - client side)
- buing sth form exp
- only global leaderboard