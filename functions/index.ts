import * as admin from 'firebase-admin';

// Initialize only if not already initialized (allows tests to initialize first)
if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

import * as functions from 'firebase-functions/v1';

// Cloud functions for user stats and creation have been moved to local implementations
// (e.g. auth_service.dart and results_service.dart).

export const processDeleteRequest = functions.firestore
  .document('delete_requests/{uid}')
  .onCreate(async (snap: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const uid = context.params.uid;
    console.log(`Processing delete request for user: ${uid}`);

    try {
      // 1. Recursive delete of user document and all subcollections
      await db.recursiveDelete(db.collection('users').doc(uid));
      console.log(`Deleted user document and subcollections for ${uid}`);

      // 2. Delete all user_results
      const resultsSnapshot = await db
        .collection('user_results')
        .where('uid', '==', uid)
        .get();
      if (!resultsSnapshot.empty) {
        const batch = db.batch();
        resultsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        console.log(`Deleted ${resultsSnapshot.size} user_results for ${uid}`);
      }

      // 3. Delete all game_progress
      const progressSnapshot = await db
        .collection('game_progress')
        .where('uid', '==', uid)
        .get();
      if (!progressSnapshot.empty) {
        const batch = db.batch();
        progressSnapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        console.log(`Deleted ${progressSnapshot.size} game_progress for ${uid}`);
      }

      // 4. Delete Firebase Auth user
      await admin.auth().deleteUser(uid);
      console.log(`Deleted Auth user ${uid}`);

      // 5. Clean up the delete_request document itself
      await snap.ref.delete();
      console.log(`Successfully completed account deletion for ${uid}`);

    } catch (error) {
      console.error(`Failed to process delete request for ${uid}:`, error);
      // We keep the delete request document so it can be manually retried if needed
    }
  });
