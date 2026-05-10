import * as admin from 'firebase-admin';

// Initialize only if not already initialized (allows tests to initialize first)
if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

// Cloud functions for user stats and creation have been moved to local implementations
// (e.g. auth_service.dart and results_service.dart).
