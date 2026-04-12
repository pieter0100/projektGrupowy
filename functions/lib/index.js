"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.cleanupUserData = exports.onUserDelete = exports.onResultWrite = exports.onUserCreate = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
// Initialize only if not already initialized (allows tests to initialize first)
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();
// onUserCreate: Tworzy users/{uid} zgodnie z firebase_db_structure.md
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
    const { uid, displayName, email, metadata, photoURL } = user;
    // Profile - with required fields: username, email, creation_date, avatar_url?
    const profile = {
        username: displayName || (email === null || email === void 0 ? void 0 : email.split('@')[0]) || 'User',
        email: email || '',
        creation_date: metadata.creationTime,
        avatar_url: photoURL || null,
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
exports.onResultWrite = functions.firestore
    .document('user_results/{resultId}')
    .onCreate(async (snap, context) => {
    const result = snap.data();
    const uid = result.uid;
    if (!uid)
        return;
    const userRef = db.collection('users').doc(uid);
    const userSnap = await userRef.get();
    if (!userSnap.exists)
        return;
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
        }
        else if (diffDays === 1) {
            // Played yesterday, increment streak
            streak = stats.currentStreak + 1;
        }
        else {
            // Missed days, reset streak
            streak = 1;
        }
    }
    stats.currentStreak = streak;
    stats.lastPlayedAt = now.toISOString();
    await userRef.update({ stats });
});
// onUserDelete: Cleans up all user data when Firebase Auth user is deleted
exports.onUserDelete = functions.auth.user().onDelete(async (user) => {
    const { uid } = user;
    console.log(`Starting cleanup for deleted user: ${uid}`);
    try {
        // 1. Delete user profile document
        console.log(`Deleting user profile for uid: ${uid}`);
        await db.collection('users').doc(uid).delete();
        // 2. Query and delete all user_results for this uid
        console.log(`Querying user_results for uid: ${uid}`);
        const resultsSnapshot = await db
            .collection('user_results')
            .where('uid', '==', uid)
            .get();
        if (!resultsSnapshot.empty) {
            console.log(`Found ${resultsSnapshot.size} user_results to delete`);
            const batch = db.batch();
            resultsSnapshot.docs.forEach((doc) => {
                batch.delete(doc.ref);
            });
            await batch.commit();
            console.log(`Deleted ${resultsSnapshot.size} user_results documents`);
        }
        // 3. Query and delete all game_progress for this uid
        console.log(`Querying game_progress for uid: ${uid}`);
        const progressSnapshot = await db
            .collection('game_progress')
            .where('uid', '==', uid)
            .get();
        if (!progressSnapshot.empty) {
            console.log(`Found ${progressSnapshot.size} game_progress to delete`);
            const batch = db.batch();
            progressSnapshot.docs.forEach((doc) => {
                batch.delete(doc.ref);
            });
            await batch.commit();
            console.log(`Deleted ${progressSnapshot.size} game_progress documents`);
        }
        console.log(`Successfully completed cleanup for user: ${uid}`);
    }
    catch (error) {
        console.error(`Error cleaning up user data for uid: ${uid}`, error);
        // Log error but don't throw - we want the function to complete even if cleanup fails
        // to avoid orphaned auth users
        throw new functions.https.HttpsError('internal', `Failed to clean up user data for uid: ${uid}. Error: ${error}`);
    }
});
// cleanupUserData: Callable HTTP function for deleting user data
// Called directly from Dart app after auth user deletion
exports.cleanupUserData = functions.https.onCall(async (data, context) => {
    const uid = data.uid;
    console.log(`cleanupUserData called for uid: ${uid}, auth context: ${context.auth ? 'YES' : 'NO'}`);
    if (!uid) {
        throw new functions.https.HttpsError('invalid-argument', 'uid is required');
    }
    try {
        // 1. Delete user profile document
        console.log(`Deleting user profile for uid: ${uid}`);
        await db.collection('users').doc(uid).delete();
        // 2. Query and delete all user_results
        console.log(`Querying user_results for uid: ${uid}`);
        const resultsSnapshot = await db
            .collection('user_results')
            .where('uid', '==', uid)
            .get();
        if (!resultsSnapshot.empty) {
            console.log(`Found ${resultsSnapshot.size} user_results to delete`);
            const batch = db.batch();
            resultsSnapshot.docs.forEach((doc) => {
                batch.delete(doc.ref);
            });
            await batch.commit();
            console.log(`Deleted ${resultsSnapshot.size} user_results documents`);
        }
        // 3. Query and delete all game_progress
        console.log(`Querying game_progress for uid: ${uid}`);
        const progressSnapshot = await db
            .collection('game_progress')
            .where('uid', '==', uid)
            .get();
        if (!progressSnapshot.empty) {
            console.log(`Found ${progressSnapshot.size} game_progress to delete`);
            const batch = db.batch();
            progressSnapshot.docs.forEach((doc) => {
                batch.delete(doc.ref);
            });
            await batch.commit();
            console.log(`Deleted ${progressSnapshot.size} game_progress documents`);
        }
        console.log(`Successfully completed cleanup for user: ${uid}`);
        return { success: true, message: `Cleanup completed for user: ${uid}` };
    }
    catch (error) {
        console.error(`Error in cleanupUserData for uid: ${uid}`, error);
        throw new functions.https.HttpsError('internal', `Failed to clean up user data for uid: ${uid}. Error: ${error}`);
    }
});
//# sourceMappingURL=index.js.map