// Firestore security rules tests for emulator
// Run with: firebase emulators:exec --project projektgrupowy-ba8f2 --only firestore "npm test"

const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const fs = require('fs');

const PROJECT_ID = "projektgrupowy-ba8f2";
const RULES_PATH = "firestore.rules";

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(RULES_PATH, "utf8")
    }
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

describe("Firestore security rules", () => {
  it("allows users to read/write their own user document", async () => {
    const context = testEnv.authenticatedContext("alice", { sub: "alice" });
    const db = context.firestore();
    const userDoc = db.collection("users").doc("alice");
    await assertSucceeds(userDoc.set({ uid: "alice", name: "Alice" }));
    await assertSucceeds(userDoc.get());
    await assertSucceeds(userDoc.update({ name: "Alice Updated" }));
  });

  it("denies users from reading/writing others' user documents", async () => {
    const context = testEnv.authenticatedContext("bob", { sub: "bob" });
    const db = context.firestore();
    const userDoc = db.collection("users").doc("alice");
    await assertFails(userDoc.get());
    await assertFails(userDoc.update({ name: "Hacker" }));
  });

  it("allows user to create user_results, but not update", async () => {
    const context = testEnv.authenticatedContext("alice", { sub: "alice" });
    const db = context.firestore();
    const resultDoc = db.collection("user_results").doc("result1");
    await assertSucceeds(resultDoc.set({ uid: "alice", score: 100 }));
    await assertFails(resultDoc.update({ score: 200 }));
  });

  it("denies user from reading/updating others' user_results", async () => {
    const context = testEnv.authenticatedContext("bob", { sub: "bob" });
    const db = context.firestore();
    const resultDoc = db.collection("user_results").doc("result1");
    await assertFails(resultDoc.get());
    await assertFails(resultDoc.update({ score: 999 }));
  });

  it("allows anyone to read public_config, only admin can write", async () => {
    const context = testEnv.authenticatedContext("anyone", { sub: "anyone" });
    const db = context.firestore();
    const configDoc = db.collection("public_config").doc("main");
    await assertSucceeds(configDoc.get());
    await assertFails(configDoc.set({ value: 1 }));
    const adminContext = testEnv.authenticatedContext("admin", { sub: "admin", admin: true });
    const adminDb = adminContext.firestore();
    await assertSucceeds(adminDb.collection("public_config").doc("main").set({ value: 2 }));
  });
});

