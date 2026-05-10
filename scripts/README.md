# Scripts Directory

Utility scripts for Firebase security rules validation and project maintenance. Provides automated validation of Firestore security rules implementation against project requirements.

## File Structure

### `validate-privacy-implementation.js`
Comprehensive validation script that checks Firestore security rules implementation against privacy and data integrity requirements. Performs syntax validation, requirement compliance checking, and collection name alignment verification.

[Detailed documentation](../code_documentation/firebase_testing.md)

---

## Firebase Deployment

Deploy Firebase configuration changes directly using Firebase CLI from your terminal:

```bash
# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes

# Deploy Cloud Functions
firebase deploy --only functions

# Deploy everything
firebase deploy
```

### Quick Workflow

```bash
# 1. Edit configuration files
code firestore.rules
code firestore.indexes.json
code functions/index.ts

# 2. Test locally (optional)
firebase emulators:start
npm test

# 3. Deploy specific component
firebase deploy --only firestore:rules

# 4. Verify in Firebase Console
# - Firestore > Rules tab
# - Firestore > Indexes tab
# - Cloud Functions
```
