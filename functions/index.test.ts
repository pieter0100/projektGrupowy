
import * as admin from 'firebase-admin';
import functionsTest from 'firebase-functions-test';

// Set environment variables BEFORE any imports
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
process.env.GCLOUD_PROJECT = 'demo-project';

// Initialize admin with emulator settings BEFORE importing functions
if (!admin.apps.length) {
  admin.initializeApp({ projectId: 'demo-project' });
}

// NOW import functions after admin is initialized
import { onUserCreate, onResultWrite } from './index';

const testEnv = functionsTest({
  projectId: 'demo-project',
});


describe('Cloud Functions (emulator)', () => {
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
    } as any;
    await testEnv.wrap(onUserCreate)(fakeUser);
    const userDoc = await admin.firestore().collection('users').doc('testuid').get();
    expect(userDoc.exists).toBe(true);
    const data = userDoc.data();
    
    // Verify structure matches firebase_db_structure.md
    expect(data?.profile.username).toBe('TestUser');
    expect(data?.profile.email).toBe('testuser@example.com');
    expect(data?.profile.creation_date).toBe('2026-01-19T12:00:00Z');
    expect(data?.profile.avatar_url).toBe('https://example.com/avatar.jpg');
    expect(data?.stats.totalGamesPlayed).toBe(0);
    expect(data?.stats.totalPoints).toBe(0);
    expect(data?.stats.currentStreak).toBe(0);
    expect(data?.stats.lastPlayedAt).toBe(null);
    expect(data?.settings).toEqual({});
  });

  it('should update stats on result write', async () => {
    const fakeSnap = testEnv.firestore.makeDocumentSnapshot(
      { uid: 'testuid', score: 100, time: 60 },
      'results/testresultid'
    );
    await testEnv.wrap(onResultWrite)(fakeSnap, {});
    const userDoc = await admin.firestore().collection('users').doc('testuid').get();
    expect(userDoc.exists).toBe(true);
    expect(userDoc.data()?.stats.totalGamesPlayed).toBeGreaterThan(0);
  });
});
