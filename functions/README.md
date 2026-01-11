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

## Notes
- Functions are defined in `functions/index.ts`.
- Update `firebase.json` if you change the functions source directory.
