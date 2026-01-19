# Manual Testing Guide - Firebase Versioning & Backup

This guide provides step-by-step instructions to manually verify that the Firebase backup and versioning system works correctly.

## Prerequisites

Before starting, ensure you have:
- Firebase CLI installed: `npm install -g firebase-tools`
- Authenticated with Firebase: `firebase login`
- Access to the Firebase project (projektgrupowy-ba8f2) `firebase use projektgrupowy-ba8f2`

- Node.js and npm installed `(node -v && npm -v)`

## Test 1: Verify Configuration Files Exist

**Goal:** Confirm all required files are in the repository.

**Steps:**
1. Check that these files exist in the project root:
   ```bash
   dir firestore.rules
   dir firestore.indexes.json
   dir firebase.json
   dir functions\index.ts
   dir code_documentation\FIREBASE_VERSIONING.md
   ```

2. Open `firestore.indexes.json` and verify it contains the `users.profile.nickname` index:
   ```bash
   type firestore.indexes.json
   ```
   Look for:
   ```json
   {
     "collectionGroup": "users",
     "fields": [
       {
         "fieldPath": "profile.nickname",
         "order": "ASCENDING"
       }
     ]
   }
   ```

**Expected Result:** All files exist and nickname index is present

---

## Test 2: Backup Commands Work (Export)

**Goal:** Verify that backup commands successfully export configuration from Firebase.

### Test 2a: Backup Rules

**Steps:**
1. Make a backup of the current file:
   ```bash
   copy firestore.rules firestore.rules.backup
   ```

2. Run the backup command:
   ```bash
   npm run backup:rules
   ```

3. Check the file was updated:
   ```bash
   type firestore.rules
   ```

4. Compare with backup to see if anything changed:
   ```bash
   fc firestore.rules firestore.rules.backup
   ```

5. Restore the backup:
   ```bash
   copy firestore.rules.backup firestore.rules
   del firestore.rules.backup
   ```

**Expected Result:** ✅ Command completes without errors, file contains Firestore security rules

### Test 2b: Backup Indexes

**Steps:**
1. Make a backup of the current file:
   ```bash
   copy firestore.indexes.json firestore.indexes.json.backup
   ```

2. Run the backup command:
   ```bash
   npm run backup:indexes
   ```

3. Check the file was updated:
   ```bash
   type firestore.indexes.json
   ```

4. Verify it's valid JSON:
   ```bash
   node -e "console.log(JSON.parse(require('fs').readFileSync('firestore.indexes.json')))"
   ```

5. Restore the backup:
   ```bash
   copy firestore.indexes.json.backup firestore.indexes.json
   del firestore.indexes.json.backup
   ```

**Expected Result:** ✅ Command completes without errors, file contains valid JSON with indexes array

### Test 2c: Backup All

**Steps:**
1. Run backup all command:
   ```bash
   npm run backup:all
   ```

2. Verify both files were updated (check file timestamps):
   ```bash
   dir firestore.rules
   dir firestore.indexes.json
   ```

**Expected Result:** ✅ Both backup commands run successfully

---

## Test 3: Deploy Commands Work (Import)

**Goal:** Verify that deploy commands successfully upload configuration to Firebase.

**Note:** These tests deploy to your Firebase project. Use with caution in production!

### Test 3a: Deploy Rules

**Steps:**
1. Ensure you're on the correct Firebase project:
   ```bash
   firebase use
   ```
   Should show: `projektgrupowy-ba8f2` or your dev project

2. Run the deploy command:
   ```bash
   npm run deploy:rules
   ```

3. Verify deployment succeeded:
   ```bash
   firebase firestore:rules
   ```

**Expected Result:** ✅ Deploy completes without errors, rules are shown

### Test 3b: Deploy Indexes

**Steps:**
1. Run the deploy command:
   ```bash
   npm run deploy:indexes
   ```

2. Verify deployment succeeded:
   ```bash
   firebase firestore:indexes
   ```

3. Check that `users.profile.nickname` index is listed

**Expected Result:** ✅ Deploy completes, nickname index is shown in the list

### Test 3c: Deploy Functions

**Steps:**
1. Ensure functions are built:
   ```bash
   cd functions
   npm install
   npm run build
   cd ..
   ```

2. Run the deploy command:
   ```bash
   npm run deploy:functions
   ```

3. Verify deployment succeeded:
   ```bash
   firebase functions:list
   ```

4. Should see:
   - `onUserCreate`
   - `onResultWrite`

**Expected Result:** ✅ Functions deploy successfully and are listed

### Test 3d: Deploy All

**Steps:**
1. Run deploy all command:
   ```bash
   npm run deploy:all
   ```

2. Verify all three deployed:
   ```bash
   firebase firestore:rules
   firebase firestore:indexes
   firebase functions:list
   ```

**Expected Result:** ✅ Rules, indexes, and functions all deploy successfully

---

## Test 4: Environment Switching

**Goal:** Verify you can switch between dev and prod environments.

**Steps:**
1. List current project:
   ```bash
   firebase use
   ```

2. If you have multiple projects, set up aliases:
   ```bash
   firebase use --add
   ```
   Follow prompts to add dev and prod aliases

3. Switch between environments:
   ```bash
   firebase use dev
   firebase use prod
   ```

4. Verify current project:
   ```bash
   firebase projects:list
   firebase use
   ```

**Expected Result:** ✅ Can switch between projects, correct project is active

---

## Test 5: Full Backup → Commit → Deploy Cycle

**Goal:** Complete end-to-end test of the versioning workflow.

**Steps:**

### Step 1: Make a small change locally
1. Open `firestore.rules` in a text editor
2. Add a comment at the top:
   ```
   // Test change - versioning test
   ```
3. Save the file

### Step 2: See the change in Git
```bash
git status
git diff firestore.rules
```
Should show your comment

### Step 3: Commit the change
```bash
git add firestore.rules
git commit -m "Test: Verify versioning workflow"
```

### Step 4: Deploy to Firebase
```bash
npm run deploy:rules
```

### Step 5: Backup from Firebase
```bash
npm run backup:rules
```

### Step 6: Verify the change persisted
```bash
type firestore.rules
```
Should still contain your comment

### Step 7: Check Git history
```bash
git log --oneline -5
```
Your commit should be visible

### Step 8: Revert the test change
```bash
git revert HEAD
```
This creates a new commit that undoes your test comment

### Step 9: Deploy the revert
```bash
npm run deploy:rules
```

### Step 10: Verify revert worked
```bash
npm run backup:rules
type firestore.rules
```
Your comment should be gone

**Expected Result:** ✅ Complete cycle works: change → commit → deploy → backup → revert → deploy

---

## Test 6: Test with Firebase Emulator

**Goal:** Verify backup/deploy works with local emulator.

**Steps:**

### Step 1: Start emulator
```bash
firebase emulators:start
```
Keep this terminal open

### Step 2: In a new terminal, deploy to emulator
```bash
npm run deploy:rules
npm run deploy:indexes
```

### Step 3: Run rules tests
```bash
npm run test:rules
```

### Step 4: Verify indexes in emulator UI
Open browser to: `http://localhost:4000`
- Go to Firestore tab
- Check indexes section

**Expected Result:** ✅ Rules and indexes deploy to emulator, tests pass

---

## Test 7: Verify Nickname Index Works

**Goal:** Confirm the `users.profile.nickname` index enables queries.

**Steps:**

### Option A: Using Firebase Console

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Go to Firestore → Indexes
4. Verify `users` collection has index on `profile.nickname`

### Option B: Using Test Query

1. In Firebase Console → Firestore → Data
2. Try to query: 
   - Collection: `users`
   - Where: `profile.nickname == 'testuser'`
3. Query should execute without "index required" error

**Expected Result:** ✅ Index exists and queries work without errors

---

## Test 8: Disaster Recovery Simulation

**Goal:** Verify you can rollback to previous versions.

**Steps:**

### Step 1: Check current state
```bash
git log --oneline firestore.rules
```
Note the current commit hash

### Step 2: Make a breaking change
1. Open `firestore.rules`
2. Delete all content and replace with:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if false; // BREAKS EVERYTHING!
       }
     }
   }
   ```
3. Save the file

### Step 3: Commit the bad change
```bash
git add firestore.rules
git commit -m "Test: Simulate bad rules"
```

### Step 4: Deploy the bad rules
```bash
npm run deploy:rules
```

### Step 5: Realize the mistake, check history
```bash
git log --oneline firestore.rules -5
```

### Step 6: Revert to previous working version
```bash
git revert HEAD
```

### Step 7: Deploy the fixed rules
```bash
npm run deploy:rules
```

### Step 8: Verify rules are restored
```bash
npm run backup:rules
type firestore.rules
```
Rules should be back to normal

**Expected Result:** ✅ Can recover from bad deployment using Git history

---

## Troubleshooting

### Problem: "Firebase CLI not found"
**Solution:**
```bash
npm install -g firebase-tools
firebase login
```

### Problem: "Permission denied" during deploy
**Solution:**
```bash
firebase login --reauth
firebase projects:list
firebase use projektgrupowy-ba8f2
```

### Problem: Backup command outputs empty file
**Solution:**
- No rules/indexes deployed yet in Firebase
- Deploy first, then backup will work:
  ```bash
  npm run deploy:all
  npm run backup:all
  ```

### Problem: Tests fail with connection errors
**Solution:**
- Start Firebase emulator:
  ```bash
  firebase emulators:start
  ```
- Or ensure internet connection for cloud deployment

---

## Summary Checklist

After completing all tests, you should have verified:

- ✅ All configuration files exist in repository
- ✅ `users.profile.nickname` index is defined
- ✅ Backup commands export rules and indexes
- ✅ Deploy commands upload to Firebase
- ✅ Can switch between dev/prod environments
- ✅ Full cycle works: export → commit → deploy
- ✅ Works with Firebase emulator
- ✅ Nickname index enables queries
- ✅ Can rollback using Git history

## Next Steps

Once all manual tests pass:
- ✅ Commit your changes
- ✅ Create a Pull Request
- ✅ Document any issues encountered
- ✅ Set up CI/CD for automated deployments

---

## Additional Resources

- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore Indexes](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Cloud Functions](https://firebase.google.com/docs/functions)
