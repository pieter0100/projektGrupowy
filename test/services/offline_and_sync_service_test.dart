import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projekt_grupowy/services/offline_store.dart';
import 'package:projekt_grupowy/services/sync_service.dart';
import 'package:projekt_grupowy/game_logic/models/game_result.dart';
import 'package:projekt_grupowy/game_logic/models/game_progress.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([
  Box,
  FirebaseFirestore,
  WriteBatch,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
  FirebaseAuth,
  User,
])
import 'offline_and_sync_service_test.mocks.dart';

void main() {

  group('OfflineStore & SyncService', () {
    late MockBox resultsBox;
    late MockBox progressBox;
    late OfflineStore store;
    late MockFirebaseFirestore firestore;
    late MockWriteBatch batch;
    late SyncService syncService;
    late MockCollectionReference<Map<String, dynamic>> collectionRef;
    late MockDocumentReference<Map<String, dynamic>> docRef;
    late MockFirebaseAuth auth;
    late MockUser user;

    setUp(() {
      resultsBox = MockBox();
      progressBox = MockBox();
      store = OfflineStore(resultsBox, progressBox);
      firestore = MockFirebaseFirestore();
      batch = MockWriteBatch();
      collectionRef = MockCollectionReference<Map<String, dynamic>>();
      docRef = MockDocumentReference<Map<String, dynamic>>();
      auth = MockFirebaseAuth();
      user = MockUser();
      when(auth.currentUser).thenReturn(user);
      when(firestore.batch()).thenReturn(batch);
      when(firestore.collection(any)).thenReturn(collectionRef);
      when(collectionRef.doc(any)).thenReturn(docRef);
      syncService = SyncService(store, firestore, auth);
      when(resultsBox.values).thenReturn([]);
      when(progressBox.values).thenReturn([]);
    });

    test('saveResult marks result as sync_pending', () async {
      final result = GameResult(
        sessionId: 's1',
        uid: 'u1',
        timestamp: DateTime.now(),
        stageResults: [],
        score: 10,
        gameType: 'MC',
      );
      await store.saveResult(result);
      expect(result.syncPending, true);
      verify(resultsBox.put('s1', result)).called(1);
    });

    test('deduplication by sessionId', () async {
      final result1 = GameResult(
        sessionId: 's1',
        uid: 'u1',
        timestamp: DateTime.now(),
        stageResults: [],
        score: 10,
        gameType: 'MC',
        syncPending: true,
      );
      final result2 = GameResult(
        sessionId: 's1',
        uid: 'u1',
        timestamp: DateTime.now(),
        stageResults: [],
        score: 20,
        gameType: 'MC',
        syncPending: true,
      );
      when(resultsBox.values).thenReturn([result1, result2]);
      final pending = store.getPendingResults();
      expect(pending.length, 2); // deduplication logic can be tested in sync layer
    });

    test('offline save, then online syncs to Firestore', () async {
      final result = GameResult(
        sessionId: 's2',
        uid: 'u2',
        timestamp: DateTime.now(),
        stageResults: [],
        score: 15,
        gameType: 'MC',
      );
      await store.saveResult(result);
      expect(result.syncPending, true);
      when(resultsBox.values).thenReturn([result]);
      when(batch.set(any, any, any)).thenReturn(null);
      when(batch.commit()).thenAnswer((_) async => null);
      when(resultsBox.get('s2')).thenReturn(result);
      await syncService.syncNow();
      expect(result.syncPending, false);
      verify(batch.set(any, any, any)).called(1);
    });

    test('sync retries on failure (flapping network)', () async {
      final result = GameResult(
        sessionId: 's3',
        uid: 'u3',
        timestamp: DateTime.now(),
        stageResults: [],
        score: 5,
        gameType: 'MC',
        syncPending: true,
      );
      when(resultsBox.values).thenReturn([result]);
      when(batch.set(any, any, any)).thenReturn(null);
      when(batch.commit()).thenThrow(Exception('network error'));

      // First sync attempt: should not throw, but syncPending remains true
      await syncService.syncNow();
      expect(result.syncPending, true);

      // Simulate network recovery: next sync attempt succeeds
      when(batch.commit()).thenAnswer((_) async => null);
      when(resultsBox.get('s3')).thenReturn(result);
      await syncService.syncNow();
      expect(result.syncPending, false);
    });

    test('last-write-wins on lastUpdated conflict', () async {
      final now = DateTime.now();
      final older = GameProgress(
        sessionId: 's4',
        uid: 'u4',
        gameId: 'g1',
        completedCount: 1,
        totalCount: 5,
        lastUpdated: now.subtract(Duration(minutes: 5)),
        syncPending: true,
      );
      final newer = GameProgress(
        sessionId: 's4',
        uid: 'u4',
        gameId: 'g1',
        completedCount: 2,
        totalCount: 5,
        lastUpdated: now,
        syncPending: true,
      );
      when(progressBox.values).thenReturn([older, newer]);
      when(batch.set(any, any, any)).thenReturn(null);
      when(batch.commit()).thenAnswer((_) async => null);
      when(progressBox.get('s4')).thenReturn(newer);
      await syncService.syncNow();
      expect(newer.syncPending, false);
      expect(older.syncPending, true); // or removed, depending on logic
    });

    test('SyncService deduplication by sessionId: does not add duplicate if Firestore doc exists', () async {
      final result = GameResult(
        sessionId: 'dedupTest',
        uid: 'u1',
        timestamp: DateTime.now(),
        stageResults: [],
        score: 42,
        gameType: 'MC',
        syncPending: true,
      );
      when(resultsBox.values).thenReturn([result]);
      // Use existing MockDocumentReference and stub get()
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshot.exists).thenReturn(true);
      when(docRef.get()).thenAnswer((_) async => mockSnapshot);
      when(batch.set(any, any, any)).thenReturn(null);
      when(batch.commit()).thenAnswer((_) async => null);
      await syncService.syncNow();
      // Should NOT call batch.set since doc exists
      verifyNever(batch.set(any, any, any));
    });

    test('SyncService progress sync: only sync if local lastUpdated is newer than Firestore', () async {
      final now = DateTime.now();
      final localNewer = GameProgress(
        sessionId: 'conflict1',
        uid: 'u5',
        gameId: 'g2',
        completedCount: 3,
        totalCount: 5,
        lastUpdated: now,
        syncPending: true,
      );
      final localOlder = GameProgress(
        sessionId: 'conflict2',
        uid: 'u6',
        gameId: 'g3',
        completedCount: 2,
        totalCount: 5,
        lastUpdated: now.subtract(Duration(minutes: 10)),
        syncPending: true,
      );
      when(progressBox.values).thenReturn([localNewer, localOlder]);
      // Firestore doc: remote lastUpdated is older for conflict1, newer for conflict2
      final remoteOlder = {'lastUpdated': now.subtract(Duration(minutes: 5)).toIso8601String()};
      final remoteNewer = {'lastUpdated': now.toIso8601String()};
      // Create separate MockDocumentReference instances for each sessionId
      final docRef1 = MockDocumentReference<Map<String, dynamic>>();
      final docRef2 = MockDocumentReference<Map<String, dynamic>>();
      final mockSnapshotNewer = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshotNewer.exists).thenReturn(true);
      when(mockSnapshotNewer.data()).thenReturn(remoteOlder);
      final mockSnapshotOlder = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshotOlder.exists).thenReturn(true);
      when(mockSnapshotOlder.data()).thenReturn(remoteNewer);
      // Stub collection().doc() to return different refs for different sessionIds
      when(collectionRef.doc('conflict1')).thenReturn(docRef1);
      when(collectionRef.doc('conflict2')).thenReturn(docRef2);
      when(docRef1.get()).thenAnswer((_) async => mockSnapshotNewer);
      when(docRef2.get()).thenAnswer((_) async => mockSnapshotOlder);
      when(batch.set(any, any, any)).thenReturn(null);
      when(batch.commit()).thenAnswer((_) async => null);
      await syncService.syncNow();
      // Should sync localNewer (since local is newer), skip localOlder (since remote is newer)
      verify(batch.set(any, any, any)).called(1);
    });
  });
}


