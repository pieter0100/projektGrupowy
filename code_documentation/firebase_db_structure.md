# Firebase Authentication & Firestore Database Structure

## 1. Authentication
- Managed by Firebase Authentication
- User signs in with email and password
- UID is generated and used as the primary user identifier

## 2. Firestore Database Structure

```
Firestore Database
│
├── users/
│   ├── {uid}/
│   │   ├── profile: { displayName, age }
│   │   ├── stats: { totalGamesPlayed, totalPoints, currentStreak, lastPlayedAt }
│   │   ├── settings: { ... }
│   │   └── (subcollection) levelProgress/
│   │       ├── {levelId}/
│   │       │   ├── levelId
│   │       │   ├── bestScore
│   │       │   ├── bestTimeSeconds
│   │       │   ├── attempts
│   │       │   ├── completed
│   │       │   ├── firstCompletedAt
│   │       │   └── lastPlayedAt
│   │       └── ...
│   └── ...
│
├── levels/
│   ├── {levelId}/
│   │   ├── levelNumber
│   │   ├── name
│   │   ├── description
│   │   ├── unlockRequirements: { minPoints, previousLevelId }
│   │   ├── rewards: { points }
│   │   └── isRevision
│   └── ...
│
└── leaderboards/
    ├── global/
    │   ├── entries[]: [ { playerId, playerName, streak, dateAchieved } ]
    │   └── lastUpdated
    └── level_{levelId}/
        ├── entries[]: [ { playerId, playerName, streak, dateAchieved } ]
        └── lastUpdated
```

## 3. Zasady
- Po rejestracji użytkownika (email+hasło) tworzony jest dokument users/{uid}.
- Stan zalogowania wynika wyłącznie z Firebase Auth (onAuthStateChanged).
- Hive/local storage NIE przechowuje stanu zalogowania.
- Hive może przechowywać cache/profil/postęp, ale nie decyduje o auth/routingu.

## 4. Minimalny dokument użytkownika (users/{uid})
```json
{
  "profile": {
    "displayName": "Jan Kowalski",
    "age": 20
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

## 5. levelProgress (users/{uid}/levelProgress/{levelId})
```json
{
  "levelId": "multiply-by-2",
  "bestScore": 10,
  "bestTimeSeconds": 0,
  "attempts": 1,
  "completed": true,
  "firstCompletedAt": "2025-12-25T12:00:00Z",
  "lastPlayedAt": "2025-12-25T12:00:00Z"
}
```

---

**Note:**
- Firestore does not enforce a schema – your application must follow it in code.
- Security rules can require the presence of fields, but cannot enforce the full structure.
