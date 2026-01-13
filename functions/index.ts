
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// onUserCreate: Creates users/{uid} with username, email, creation_date, avatar_url (optional)
export const onUserCreate = functions.auth.user().onCreate(async (user: admin.auth.UserRecord) => {
  const { uid, email, displayName, photoURL, metadata } = user;
  const userProfile = {
    username: displayName || '',
    email: email || '',
    creation_date: metadata.creationTime || new Date().toISOString(),
    avatar_url: photoURL || '',
    // Add other default fields if needed
  };
  await db.collection('users').doc(uid).set(userProfile);
});

// onResultWrite: Updates aggregates on CREATE only
export const onResultWrite = functions.firestore
  .document('results/{resultId}')
  .onCreate(async (snap: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const result = snap.data() as { uid: string; score?: number; time?: number };
    const uid = result.uid;
    if (!uid) return;

    const userStatsRef = db.collection('users').doc(uid).collection('stats').doc('aggregates');
    const userStatsSnap = await userStatsRef.get();
    let stats = userStatsSnap.exists && userStatsSnap.data() ? userStatsSnap.data() as any : {
      totalScore: 0,
      gamesPlayed: 0,
      bestScore: 0,
      totalTime: 0,
      averageScore: 0,
    };

    // Update stats
    stats.totalScore += result.score || 0;
    stats.gamesPlayed += 1;
    stats.bestScore = Math.max(stats.bestScore, result.score || 0);
    stats.totalTime += result.time || 0;
    stats.averageScore = stats.gamesPlayed > 0 ? stats.totalScore / stats.gamesPlayed : 0;

    await userStatsRef.set(stats);
  });
