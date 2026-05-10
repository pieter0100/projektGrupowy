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
exports.processDeleteRequest = void 0;
const admin = __importStar(require("firebase-admin"));
// Initialize only if not already initialized (allows tests to initialize first)
if (!admin.apps.length) {
    admin.initializeApp();
}
const db = admin.firestore();
const functions = __importStar(require("firebase-functions/v1"));
// Cloud functions for user stats and creation have been moved to local implementations
// (e.g. auth_service.dart and results_service.dart).
exports.processDeleteRequest = functions.firestore
    .document('delete_requests/{uid}')
    .onCreate(async (snap, context) => {
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
    }
    catch (error) {
        console.error(`Failed to process delete request for ${uid}:`, error);
        // We keep the delete request document so it can be manually retried if needed
    }
});
//# sourceMappingURL=index.js.map