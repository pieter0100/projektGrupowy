# Firebase Cloud Functions

## Overview

This directory contains Firebase Cloud Functions that handle server-side operations for user profile initialization and statistics aggregation.

## Functions

### `onUserCreate`
**Trigger:** Firebase Authentication user creation  
**Purpose:** Automatically initializes user profile when a new account is created

**Creates document:** `users/{uid}`
```json
{
  "profile": {
    "username": "User Name",
    "email": "user@example.com",
    "creation_date": "2026-01-19T12:00:00Z",
    "avatar_url": null
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

### `onResultWrite`
**Trigger:** New document created in `user_results/` collection  
**Purpose:** Updates user statistics when a game result is saved

**Updates:** `users/{uid}/stats`
- Increments `totalGamesPlayed`
- Adds to `totalPoints`
- Calculates `currentStreak` based on play frequency:
  - **Same day:** Maintains current streak
  - **Consecutive days:** Increments streak by 1
  - **Missed days:** Resets streak to 1
- Updates `lastPlayedAt` timestamp

**Note:** Only triggers on CREATE, not on UPDATE (prevents duplicate stat updates)


## Setup

### Prerequisites
- Node.js 18+
- Firebase CLI installed globally: `npm install -g firebase-tools`
- Firebase project configured

### Install Dependencies
```bash
npm install
```

### Build TypeScript
```bash
npm run build
```

## Development

### Run Emulator
Start Firebase emulators for local testing:
```bash
# From project root
firebase emulators:start --only firestore,auth,functions
```

Emulator UI available at: `http://127.0.0.1:4000`

## Testing

### Run All Tests
```bash
npm test
```

### Run Unit Tests Only
Tests pure stat calculation logic without emulator:
```bash
npm run test:unit
```

### Run Emulator Tests
**Requires emulator running first:**

Terminal 1:
```bash
cd ..
firebase emulators:start --only firestore,auth
```

Terminal 2:
```bash
cd functions
npm test
```

### Test Files
- **`userStats.unit.test.ts`** - Pure function tests for stat aggregation logic
- **`index.test.ts`** - Integration tests using Firebase emulator

## Deployment

### Deploy All Functions
```bash
npm run deploy
```

### Deploy Specific Function
```bash
firebase deploy --only functions:onUserCreate
firebase deploy --only functions:onResultWrite
```

## Project Structure

```
functions/
├── index.ts              # Main functions implementation
├── index.test.ts         # Emulator integration tests
├── userStats.unit.test.ts # Pure unit tests
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
├── jest.config.js        # Jest test configuration
├── .gitignore            # Git ignore rules
└── lib/                  # Build output (gitignored)
```

## Scripts

| Script | Description |
|--------|-------------|
| `npm run build` | Compile TypeScript to JavaScript |
| `npm run build:watch` | Watch mode - auto-rebuild on changes |
| `npm test` | Run all tests (unit + emulator) |
| `npm run test:unit` | Run unit tests only |
| `npm run deploy` | Deploy functions to Firebase |
| `npm run logs` | View function logs from production |



### Common Issues

**Issue:** Tests fail with "Could not load credentials"  
**Solution:** Ensure emulator is running before tests

**Issue:** Functions don't trigger in emulator  
**Solution:** Check emulator UI at `http://127.0.0.1:4000` for errors

**Issue:** TypeScript compilation errors  
**Solution:** Run `npm run build` to see detailed errors


**Emulator detection:**
- `FIRESTORE_EMULATOR_HOST=localhost:8080`
- `FIREBASE_AUTH_EMULATOR_HOST=localhost:9099`





