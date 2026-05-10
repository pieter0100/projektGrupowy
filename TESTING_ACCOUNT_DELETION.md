# Account Deletion Feature - Testing Guide

## Overview
The account deletion feature has been fully implemented with comprehensive testing across multiple layers:

1. **Cloud Function Tests** - Verify backend cleanup logic
2. **Integration Tests** - Full end-to-end testing with Firebase Emulator
3. **Manual E2E Testing** - UI/UX validation in the app

---

## 📋 Prerequisites

### Required Setup
```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Install project dependencies
dart pub get
flutter pub get

# 3. Install Cloud Function dependencies
cd functions && npm install && cd ..
```

### Firebase Emulator Setup
```bash
# Start Firebase Emulator Suite (Auth + Firestore)
firebase emulators:start --only=auth,firestore

# Output will show:
# ✔ All emulators ready! It is now safe to run your tests.
# Auth Emulator running on http://localhost:9099
# Firestore Emulator running on http://localhost:8080
```

---

## 🧪 Running Tests

### ⚠️ IMPORTANT: Start Firebase Emulator FIRST!

All tests require Firebase Emulator to be running on:
- **Auth Emulator:** http://localhost:9099
- **Firestore Emulator:** http://localhost:8080

### Option 1: Cloud Function Tests (Recommended First)
Tests the backend cleanup logic in isolation.

**Terminal 1** - Start Firebase Emulator:
```bash
firebase emulators:start --only=auth,firestore
```
Wait for output: `✔ All emulators ready! It is now safe to run your tests.`

**Terminal 2** - Run tests:
```bash
cd functions
npm test
```

Expected output:
```
 PASS  ./userStats.unit.test.ts
 PASS  ./index.test.ts
  Account Deletion Integration Tests
    ✓ Re-authentication succeeds with correct password
    ✓ Re-authentication fails with incorrect password
    ✓ Account deletion removes Firebase Auth user
    ✓ Account deletion removes Firestore user document
    ✓ Account deletion removes all user_results documents
    ✓ Account deletion removes all game_progress documents
    ✓ Offline store clearAllData removes all cached data
    ✓ Offline store clearUserData removes only user-specific data

Tests:  7 passed, 7 total
```

### Option 2: Flutter Integration Tests
Tests the full flow with real Firebase Emulator.

**Terminal 1** - Start emulator:
```bash
firebase emulators:start --only=auth,firestore
```

**Terminal 2** - Run integration tests:
```bash
flutter test integration_test/account_deletion_integration_test.dart
```

**Expected output:**
```
✓ Account Deletion Integration Tests
  Account deletion removes Firebase Auth user
  Account deletion removes Firestore user document
  Account deletion removes all user_results documents
  Account deletion removes all game_progress documents
  Re-authentication succeeds with correct password
  Re-authentication fails with incorrect password
  Offline store clearAllData removes all cached data
  Offline store clearUserData removes only user-specific data
```

---

## 🖥️ Manual E2E Testing (In App)

### Setup
1. Make sure Firebase Emulator is running
2. Run the app: `flutter run -d chrome` (or Android/iOS)

### Test Steps

#### Step 1: Create Account
```
1. Tap "Sign Up"
2. Enter:
   - Nick: TestUser123
   - Email: test@example.com
   - Password: TestPassword123!
3. Tap "Sign up"
```

#### Step 2: Navigate to Profile
```
1. After login, tap profile/settings icon
2. You should see "Settings" section
3. Locate "Delete Account" button
```

#### Step 3: Delete Account
```
1. Tap "Delete Account"
2. ⚠️ Warning dialog appears:
   - Title: "Delete Account?" (red icon)
   - Warning: "This action cannot be undone..."
   - Password field
3. Enter password: TestPassword123!
4. Tap "Delete Account" button
5. Loading spinner appears
6. Success message: "Account deleted successfully. Redirecting to login..."
7. Auto-redirect to login screen after 2 seconds
```

#### Step 4: Verify Deletion
```
1. Try to login with deleted account
2. Should fail with error:
   - "There is no user record corresponding to this identifier"
   OR
   - "The password is invalid or the user does not have a password."
```

---

## 🔍 Verification Checklist

### Cloud Function Execution
- [ ] Firebase Emulator shows cleanup logs in console
- [ ] user document deleted from Firestore
- [ ] All user_results documents deleted
- [ ] All game_progress documents deleted

### UI/UX Behavior
- [ ] Delete Account button visible in Profile Settings
- [ ] Warning icon and red text on button
- [ ] Dialog appears on button tap
- [ ] Password input field works (show/hide toggle)
- [ ] Loading spinner during deletion
- [ ] Success message displays green SnackBar
- [ ] Auto-redirect to login after deletion
- [ ] Deleted account cannot login

### Error Handling
- [ ] Wrong password shows "Incorrect password" error
- [ ] Network error shows appropriate message
- [ ] Loading state disabled button during process
- [ ] Proper error SnackBar styling (red background)

---

## 🛠️ Troubleshooting

### "Could not connect to Firestore Emulator"
```bash
# Ensure emulator is running
firebase emulators:start --only=auth,firestore

# Check logs for port conflicts
# Default ports: Auth=9099, Firestore=8080
```

### Tests timeout or hang
```bash
# Increase test timeout in integration test or:
# 1. Check emulator is responsive
# 2. Check network connectivity
# 3. Try restarting emulator
```

### "Password must be at least 8 characters..."
- Test password must match AuthService requirements:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character (!@#$%^&*-_+=[]{}; etc.)

**Valid test password:** `TestPassword123!`

### Firestore data not deleting
- [ ] Cloud Function is deployed (check `firebase emulators:start` logs)
- [ ] onChange trigger is active
- [ ] Rules allow deletion (check [firestore.rules](firestore.rules))
- [ ] User is properly authenticated

---

## 📊 Test Coverage

### What's Tested

| Component | Coverage | Level |
|-----------|----------|-------|
| Cloud Function cleanup | 8 scenarios | Integration |
| AuthService reauthenticate | 3 scenarios | Integration |
| AuthService deleteAccount | 2 scenarios | Integration |
| OfflineStore clearUserData | 1 scenario | Integration |
| OfflineStore clearAllData | 1 scenario | Integration |
| UI Dialog flow | Manual | E2E |
| Error handling | Manual | E2E |

### Test Files

- `integration_test/account_deletion_integration_test.dart` - Comprehensive integration tests
- `functions/index.test.ts` - Cloud Function tests
- Manual testing via app UI

---

## 🚀 Quick Start Command Reference

### ⚠️ ALWAYS START EMULATOR FIRST!

```bash
# 1. Start emulator (Terminal 1) - RUN THIS FIRST AND LET IT RUN
firebase emulators:start --only=auth,firestore
# Wait for: ✔ All emulators ready! It is now safe to run your tests.

# 2. Run Cloud Function tests (Terminal 2)
cd functions && npm test

# 3. Run Flutter integration tests (Terminal 3)
flutter test integration_test/account_deletion_integration_test.dart

# 4. Test in app (Terminal 4)
flutter run -d chrome
```

**DO NOT skip step 1** - tests will fail/timeout without the emulator running!


---

## 📝 Notes

- All tests use Firebase Emulator - no production data touched
- Integration tests create temporary users that are cleaned up
- Tests are independent and can run in any order
- Emulator data persists between test runs (intentional)
- Use `firebase emulators:start --import ./emulator-data` to load saved state

---

For questions or issues, check:
- [firestore.rules](../firestore.rules) - Security configuration
- [functions/index.ts](../functions/index.ts) - Cloud Function logic
- [lib/services/auth_service.dart](../lib/services/auth_service.dart) - Auth logic
- [lib/screens/profile_screen.dart](../lib/screens/profile_screen.dart) - UI implementation
