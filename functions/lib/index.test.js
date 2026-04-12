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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const admin = __importStar(require("firebase-admin"));
const firebase_functions_test_1 = __importDefault(require("firebase-functions-test"));
// Set environment variables BEFORE any imports
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
process.env.GCLOUD_PROJECT = 'demo-project';
// Initialize admin with emulator settings BEFORE importing functions
if (!admin.apps.length) {
    admin.initializeApp({ projectId: 'demo-project' });
}
// NOW import functions after admin is initialized
const index_1 = require("./index");
const testEnv = (0, firebase_functions_test_1.default)({
    projectId: 'demo-project',
});
describe('Cloud Functions (emulator)', () => {
    // Increase timeout for emulator tests (120 seconds for integration tests)
    jest.setTimeout(120000);
    beforeAll(async () => {
        // Admin already initialized above
    });
    afterAll(async () => {
        testEnv.cleanup();
        await admin.app().delete();
    });
    it('should create user profile on user creation', async () => {
        const fakeUser = {
            uid: 'testuid',
            displayName: 'TestUser',
            email: 'testuser@example.com',
            photoURL: 'https://example.com/avatar.jpg',
            metadata: {
                creationTime: '2026-01-19T12:00:00Z',
            },
        };
        await testEnv.wrap(index_1.onUserCreate)(fakeUser);
        const userDoc = await admin.firestore().collection('users').doc('testuid').get();
        expect(userDoc.exists).toBe(true);
        const data = userDoc.data();
        // Verify structure matches firebase_db_structure.md
        expect(data === null || data === void 0 ? void 0 : data.profile.username).toBe('TestUser');
        expect(data === null || data === void 0 ? void 0 : data.profile.email).toBe('testuser@example.com');
        expect(data === null || data === void 0 ? void 0 : data.profile.creation_date).toBe('2026-01-19T12:00:00Z');
        expect(data === null || data === void 0 ? void 0 : data.profile.avatar_url).toBe('https://example.com/avatar.jpg');
        expect(data === null || data === void 0 ? void 0 : data.stats.totalGamesPlayed).toBe(0);
        expect(data === null || data === void 0 ? void 0 : data.stats.totalPoints).toBe(0);
        expect(data === null || data === void 0 ? void 0 : data.stats.currentStreak).toBe(0);
        expect(data === null || data === void 0 ? void 0 : data.stats.lastPlayedAt).toBe(null);
        expect(data === null || data === void 0 ? void 0 : data.settings).toEqual({});
    });
    it('should update stats on result write', async () => {
        var _a;
        const fakeSnap = testEnv.firestore.makeDocumentSnapshot({ uid: 'testuid', score: 100, time: 60 }, 'user_results/testresultid');
        await testEnv.wrap(index_1.onResultWrite)(fakeSnap, {});
        const userDoc = await admin.firestore().collection('users').doc('testuid').get();
        expect(userDoc.exists).toBe(true);
        expect((_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.stats.totalGamesPlayed).toBeGreaterThan(0);
    });
    it('should delete all user data on user deletion', async () => {
        const deleteUid = 'deletetest-uid-' + Date.now();
        // 1. Create user profile
        await admin.firestore().collection('users').doc(deleteUid).set({
            profile: { username: 'ToDelete', email: 'delete@test.com', creation_date: new Date().toISOString() },
            stats: { totalGamesPlayed: 5, totalPoints: 500, currentStreak: 2, lastPlayedAt: new Date().toISOString() },
            settings: {},
        });
        // 2. Create some user_results
        const result1Ref = admin.firestore().collection('user_results').doc();
        await result1Ref.set({
            uid: deleteUid,
            sessionId: 'session-1',
            timestamp: new Date().toISOString(),
            score: 100,
        });
        const result2Ref = admin.firestore().collection('user_results').doc();
        await result2Ref.set({
            uid: deleteUid,
            sessionId: 'session-2',
            timestamp: new Date().toISOString(),
            score: 200,
        });
        // 3. Create some game_progress
        const progress1Ref = admin.firestore().collection('game_progress').doc();
        await progress1Ref.set({
            uid: deleteUid,
            sessionId: 'session-1',
            gameId: 'game-1',
            completedCount: 5,
            totalCount: 10,
            lastUpdated: new Date().toISOString(),
        });
        // 4. Verify data exists before deletion
        let userDoc = await admin.firestore().collection('users').doc(deleteUid).get();
        expect(userDoc.exists).toBe(true);
        let resultsSnap = await admin.firestore().collection('user_results').where('uid', '==', deleteUid).get();
        expect(resultsSnap.size).toBe(2);
        let progressSnap = await admin.firestore().collection('game_progress').where('uid', '==', deleteUid).get();
        expect(progressSnap.size).toBe(1);
        // 5. Call onUserDelete
        const fakeDeletedUser = { uid: deleteUid };
        await testEnv.wrap(index_1.onUserDelete)(fakeDeletedUser);
        // 6. Verify all data is deleted
        userDoc = await admin.firestore().collection('users').doc(deleteUid).get();
        expect(userDoc.exists).toBe(false);
        resultsSnap = await admin.firestore().collection('user_results').where('uid', '==', deleteUid).get();
        expect(resultsSnap.empty).toBe(true);
        progressSnap = await admin.firestore().collection('game_progress').where('uid', '==', deleteUid).get();
        expect(progressSnap.empty).toBe(true);
    });
});
//# sourceMappingURL=index.test.js.map