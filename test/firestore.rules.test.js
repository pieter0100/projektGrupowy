// Run with:
// npm install - to install dependencies
// npm emulator:start --only firestore - to start the Firestore emulator
// npm run test:rules - to run the tests

const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const fs = require('fs');

const PROJECT_ID = 'projektgrupowy-ba8f2';
const RULES_PATH = 'firestore.rules';

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

describe('Firestore Security Rules', () => {
  describe('Users collection', () => {
    it('should allow users to read their own profile', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('alice').set({
          profile: { displayName: 'Alice', age: 25 },
          stats: { totalGamesPlayed: 0 },
        });
      });

      await assertSucceeds(
        alice.firestore().collection('users').doc('alice').get()
      );
    });

    it('should deny users from reading other users profiles', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('bob').set({
          profile: { displayName: 'Bob', age: 30 },
        });
      });

      await assertFails(
        alice.firestore().collection('users').doc('bob').get()
      );
    });

    it('should allow users to update their own profile', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('alice').set({
          profile: { displayName: 'Alice', age: 25 },
        });
      });

      await assertSucceeds(
        alice.firestore().collection('users').doc('alice').update({
          'profile.age': 26,
        })
      );
    });

    it('should deny unauthenticated access', async () => {
      const unauth = testEnv.unauthenticatedContext();
      
      await assertFails(
        unauth.firestore().collection('users').doc('alice').get()
      );
    });

    it('should prevent users from deleting their profile', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('alice').set({
          profile: { displayName: 'Alice' },
        });
      });

      await assertFails(
        alice.firestore().collection('users').doc('alice').delete()
      );
    });
  });

  describe('Results collection', () => {
    it('should allow users to create their own results', async () => {
      const alice = testEnv.authenticatedContext('alice');

      await assertSucceeds(
        alice.firestore().collection('results').doc('result1').set({
          uid: 'alice',
          sessionId: 'session1',
          timestamp: new Date().toISOString(),
          score: 100,
        })
      );
    });

    it('should deny users from creating results for other users', async () => {
      const alice = testEnv.authenticatedContext('alice');

      await assertFails(
        alice.firestore().collection('results').doc('result1').set({
          uid: 'bob',
          sessionId: 'session1',
          timestamp: new Date().toISOString(),
          score: 100,
        })
      );
    });

    it('should allow users to read their own results', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('results').doc('result1').set({
          uid: 'alice',
          sessionId: 'session1',
          timestamp: new Date().toISOString(),
          score: 100,
        });
      });

      await assertSucceeds(
        alice.firestore().collection('results').doc('result1').get()
      );
    });

    it('should deny users from reading other users results', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('results').doc('result1').set({
          uid: 'bob',
          sessionId: 'session1',
          timestamp: new Date().toISOString(),
          score: 100,
        });
      });

      await assertFails(
        alice.firestore().collection('results').doc('result1').get()
      );
    });

    it('should prevent updates to results (immutable)', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('results').doc('result1').set({
          uid: 'alice',
          sessionId: 'session1',
          timestamp: new Date().toISOString(),
          score: 100,
        });
      });

      await assertFails(
        alice.firestore().collection('results').doc('result1').update({
          score: 200,
        })
      );
    });

    it('should prevent deletion of results', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('results').doc('result1').set({
          uid: 'alice',
          sessionId: 'session1',
          timestamp: new Date().toISOString(),
          score: 100,
        });
      });

      await assertFails(
        alice.firestore().collection('results').doc('result1').delete()
      );
    });
  });

  describe('Progress collection', () => {
    it('should allow users to create their own progress', async () => {
      const alice = testEnv.authenticatedContext('alice');

      await assertSucceeds(
        alice.firestore().collection('progress').doc('progress1').set({
          uid: 'alice',
          sessionId: 'session1',
          completedCount: 5,
          lastUpdated: new Date().toISOString(),
        })
      );
    });

    it('should allow users to update their own progress', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('progress').doc('progress1').set({
          uid: 'alice',
          sessionId: 'session1',
          completedCount: 5,
        });
      });

      await assertSucceeds(
        alice.firestore().collection('progress').doc('progress1').update({
          completedCount: 6,
        })
      );
    });

    it('should deny users from updating other users progress', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('progress').doc('progress1').set({
          uid: 'bob',
          sessionId: 'session1',
          completedCount: 5,
        });
      });

      await assertFails(
        alice.firestore().collection('progress').doc('progress1').update({
          completedCount: 6,
        })
      );
    });

    it('should prevent deletion of progress', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('progress').doc('progress1').set({
          uid: 'alice',
          sessionId: 'session1',
        });
      });

      await assertFails(
        alice.firestore().collection('progress').doc('progress1').delete()
      );
    });
  });

  describe('Levels collection', () => {
    it('should allow authenticated users to read levels', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('levels').doc('level1').set({
          name: 'Level 1',
          difficulty: 'easy',
        });
      });

      await assertSucceeds(
        alice.firestore().collection('levels').doc('level1').get()
      );
    });

    it('should deny unauthenticated users from reading levels', async () => {
      const unauth = testEnv.unauthenticatedContext();
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('levels').doc('level1').set({
          name: 'Level 1',
        });
      });

      await assertFails(
        unauth.firestore().collection('levels').doc('level1').get()
      );
    });

    it('should deny users from writing to levels', async () => {
      const alice = testEnv.authenticatedContext('alice');

      await assertFails(
        alice.firestore().collection('levels').doc('level1').set({
          name: 'Hacked Level',
        })
      );
    });
  });

  describe('Leaderboards collection', () => {
    it('should allow authenticated users to read leaderboards', async () => {
      const alice = testEnv.authenticatedContext('alice');
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('leaderboards').doc('global').set({
          entries: [],
        });
      });

      await assertSucceeds(
        alice.firestore().collection('leaderboards').doc('global').get()
      );
    });

    it('should deny users from writing to leaderboards', async () => {
      const alice = testEnv.authenticatedContext('alice');

      await assertFails(
        alice.firestore().collection('leaderboards').doc('global').set({
          entries: [{ playerId: 'alice', score: 9999 }],
        })
      );
    });
  });
});
