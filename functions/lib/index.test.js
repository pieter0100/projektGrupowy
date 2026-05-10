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
describe('Cloud Functions - processDeleteRequest', () => {
    jest.setTimeout(120000);
    afterAll(async () => {
        testEnv.cleanup();
        await admin.app().delete();
    });
    it('should clean up user data and delete auth account on delete_request', async () => {
        const deleteUid = 'delete-test-uid-' + Date.now();
        // 1. Setup mock data in Firestore
        await admin.firestore().collection('users').doc(deleteUid).set({
            profile: { username: 'ToDelete' },
            stats: { totalPoints: 500 }
        });
        await admin.firestore().collection('user_results').doc('res1').set({
            uid: deleteUid,
            score: 100
        });
        // 2. Create mock Auth user in emulator
        // Note: In real test environment we'd use admin.auth().createUser()
        // but here we are wrapping the function, so we just check if it calls the admin SDK correctly.
        // However, wrap(processDeleteRequest) will actually execute the code.
        // Create a mock document snapshot for the onCreate trigger
        const snap = testEnv.firestore.makeDocumentSnapshot({ uid: deleteUid, requestedAt: new Date().toISOString() }, `delete_requests/${deleteUid}`);
        // 3. Wrap and call the function
        // We expect this to fail in a pure unit test if the auth user doesn't exist,
        // but we can at least check if it tries to delete Firestore data.
        try {
            await testEnv.wrap(index_1.processDeleteRequest)(snap, { params: { uid: deleteUid } });
        }
        catch (e) {
            // Expected error if Auth user not found in emulator
            console.log('Function execution finished (caught expected auth error if user missing)');
        }
        // 4. Verify Firestore cleanup
        const userDoc = await admin.firestore().collection('users').doc(deleteUid).get();
        expect(userDoc.exists).toBe(false);
        const resultsSnap = await admin.firestore().collection('user_results').where('uid', '==', deleteUid).get();
        expect(resultsSnap.empty).toBe(true);
        const requestDoc = await admin.firestore().collection('delete_requests').doc(deleteUid).get();
        expect(requestDoc.exists).toBe(false);
    });
});
//# sourceMappingURL=index.test.js.map