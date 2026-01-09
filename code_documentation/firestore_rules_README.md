# Firestore Security Rules & Testing

This directory contains Firestore security rules and automated tests to ensure privacy and data integrity for Firebase project.

## Implementation Overview
- **firestore.rules**: Defines Firestore security rules.
  - Users can only read/write their own documents in `users`, `user_results`, and `game_progress` collections.
  - `user_results` documents are immutable after creation.
  - Public data (e.g., `public_config`) is readable by anyone, writable only by admin/server.
  - All user data access requires Firebase Auth and matching user ID.
- **test/firestore.rules.test.js**: Automated tests for the above rules using the Firestore Emulator.

## Required Packages
To set up the testing environment, you need to install the Firebase CLI globally if you haven't already:

```
npm install -g firebase-tools
```

Firebase emulator and testing libraries are needed to run the tests locally. Node related files were added to `.gitignore` to avoid committing them.
Install these as dev dependencies in your project root:

```
npm install --save-dev @firebase/rules-unit-testing jest firebase-tools
```

- `@firebase/rules-unit-testing`: For writing and running Firestore security rules tests.
- `jest`: Test runner.
- `firebase-tools`: To run the Firestore Emulator and execute tests.

## How to Run the Tests
1. **(Optional) Authenticate with Firebase CLI:**
   ```
   firebase login
   ```
2. **Run the Firestore Emulator and tests:**
   ```
   firebase emulators:exec --project projektgrupowy-ba8f2 --only firestore "npx jest test/firestore.rules.test.js"
   ```

This command will:
- Start the Firestore Emulator
- Run all Jest tests in `test/firestore.rules.test.js`
- Shut down the emulator automatically

## Notes
- The tests require Node.js 20+ and the latest `@firebase/rules-unit-testing`.
- If you see port (default: 8080) errors, make sure no other Firestore Emulator is running.
- If you update your security rules, re-run the tests to verify correctness.

# Deploying Firestore Rules to Firebase

When you are ready to apply your local Firestore security rules to your live Firebase project, use:

```
firebase deploy --only firestore:rules
```

This command uploads your local `firestore.rules` file to your Firebase project in the cloud. Make sure you are in the correct project directory and have selected the right Firebase project (check with `firebase use`).

For deployment, 

Ensure you have authenticated with Firebase CLI using `firebase login` before deploying.
