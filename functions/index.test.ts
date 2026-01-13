import * as admin from 'firebase-admin';
import { onUserCreate, onResultWrite } from './index';

describe('Cloud Functions', () => {
  beforeAll(() => {
    if (!admin.apps.length) {
      admin.initializeApp();
    }
  });

  it('should create user profile on user creation', async () => {
    // Simulate user creation event
    const fakeUser = {
      uid: 'testuid',
      email: 'test@example.com',
      displayName: 'TestUser',
      photoURL: 'http://example.com/avatar.png',
      metadata: { creationTime: new Date().toISOString() },
    };
    await onUserCreate(fakeUser as any);
    const userDoc = await admin.firestore().collection('users').doc('testuid').get();
    expect(userDoc.exists).toBe(true);
    expect(userDoc.data()?.email).toBe('test@example.com');
  });

  it('should update stats on result write', async () => {
    const fakeSnap = {
      data: () => ({ uid: 'testuid', score: 100, time: 60 }),
    };
    await onResultWrite(fakeSnap as any, {} as any);
    const statsDoc = await admin.firestore().collection('users').doc('testuid').collection('stats').doc('aggregates').get();
    expect(statsDoc.exists).toBe(true);
    expect(statsDoc.data()?.gamesPlayed).toBeGreaterThan(0);
  });
});
