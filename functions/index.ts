import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// onUserCreate: Tworzy users/{uid}/profile, users/{uid}/stats, users/{uid}/settings
export const onUserCreate = functions.auth.user().onCreate(async (user: admin.auth.UserRecord) => {
  const { uid, displayName } = user;
  // Profile
  const profile = {
    displayName: displayName || '',
    age: null,
  };
  // Stats
  const stats = {
    totalGamesPlayed: 0,
    totalPoints: 0,
    currentStreak: 0,
    lastPlayedAt: null,
  };
  // Settings
  const settings = {};

  await db.collection('users').doc(uid).set({ profile, stats, settings });
});

// onResultWrite: Ac users/{uid}/stats (nie podkolekcję)
export const onResultWrite = functions.firestore
  .document('results/{resultId}')
  .onCreate(async (snap: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const result = snap.data() as { uid: string; score?: number; time?: number };
    const uid = result.uid;
    if (!uid) return;

    const userRef = db.collection('users').doc(uid);
    const userSnap = await userRef.get();
    if (!userSnap.exists) return;
    const userData = userSnap.data() || {};
    const stats = userData.stats || {
      totalGamesPlayed: 0,
      totalPoints: 0,
      currentStreak: 0,
      lastPlayedAt: null,
    };

    // Update stats
    stats.totalPoints += result.score || 0;
    stats.totalGamesPlayed += 1;
    // currentStreak, lastPlayedAt można rozbudować wg potrzeb
    stats.lastPlayedAt = new Date().toISOString();

    await userRef.update({ stats });
  });
