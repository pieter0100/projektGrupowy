import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

// Initialize only if not already initialized (allows tests to initialize first)
if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

// onUserCreate: Tworzy users/{uid} zgodnie z firebase_db_structure.md
export const onUserCreate = functions.auth.user().onCreate(async (user: admin.auth.UserRecord) => {
  const { uid, displayName, email, metadata, photoURL } = user;
  // Profile - with required fields: username, email, creation_date, avatar_url?
  const profile = {
    username: displayName || email?.split('@')[0] || 'User',
    email: email || '',
    creation_date: metadata.creationTime,
    avatar_url: photoURL || null,
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

  await db.collection('users').doc(uid).set({ 
    profile, 
    stats, 
    settings,
  });
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

    // Update currentStreak
    const now = new Date();
    const nowDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    let streak = 1;
    if (stats.lastPlayedAt) {
      const last = new Date(stats.lastPlayedAt);
      const lastDay = new Date(last.getFullYear(), last.getMonth(), last.getDate());
      const diffDays = Math.floor((nowDay.getTime() - lastDay.getTime()) / (1000 * 60 * 60 * 24));
      if (diffDays === 0) {
        // Played today, keep current
        streak = stats.currentStreak;
      } else if (diffDays === 1) {
        // Played yesterday, increment streak
        streak = stats.currentStreak + 1;
      } else {
        // Missed days, reset streak
        streak = 1;
      }
    }
    stats.currentStreak = streak;
    stats.lastPlayedAt = now.toISOString();

    await userRef.update({ stats });
  });
