
import * as admin from 'firebase-admin';
import * as functionsTestLib from 'firebase-functions-test';
import { onUserCreate, onResultWrite } from './index';

const testEnv = functionsTestLib({
  projectId: 'demo-project',
});


describe('Cloud Functions (emulator)', () => {
  beforeAll(() => {
    process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
    process.env.GCLOUD_PROJECT = 'demo-project';
    if (!admin.apps.length) {
      admin.initializeApp();
    }
  });

  afterAll(() => {
    testEnv.cleanup();
  });

  it('should create user profile on user creation', async () => {
    const fakeUser = {
      uid: 'testuid',
      displayName: 'TestUser',
    } as any;
    await testEnv.wrap(onUserCreate)(fakeUser);
    const userDoc = await admin.firestore().collection('users').doc('testuid').get();
    expect(userDoc.exists).toBe(true);
    expect(userDoc.data()?.profile.displayName).toBe('TestUser');
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
