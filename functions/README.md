# Firebase Cloud Functions Setup

## Prerequisites
- Node.js (v16 or later recommended)
- npm (comes with Node.js)
- Firebase CLI (`npm install -g firebase-tools`)

## Installation Steps

1. **Navigate to the functions directory:**
   ```
   cd functions
   ```

2. **Install dependencies:**
   ```
   npm install firebase-functions firebase-admin
   ```

3. **Emulator setup (for local testing):**
   - Install the Firebase Emulator Suite:
     ```
     firebase setup:emulators:firestore
     firebase setup:emulators:auth
     ```
   - Start the emulator:
     ```
     firebase emulators:start
     ```

4. **Deploy functions to Firebase (when ready):**
   ```
   firebase deploy --only functions
   ```

5. **Testing functions locally:**
   Since Jest is set up, you can run tests using:
   ```
   npm test
   ```
   If you haven't set up Jest yet, you can do so by installing it:
   ```
   npm install --save-dev jest @types/jest ts-jest
   ```
   
   `npm test` will find all files with `.test.ts` or `.spec.ts` extensions and run the tests. If you want to run a specific test file, you can use:
   ```
   npx test functions/.test.ts
   ```

## Notes
- Functions are defined in `functions/index.ts`.
- Update `firebase.json` if you change the functions source directory.

