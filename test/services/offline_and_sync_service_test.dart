import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importy Twoich klas
import 'package:projekt_grupowy/services/offline_store.dart';
import 'package:projekt_grupowy/services/sync_service.dart';
import 'package:projekt_grupowy/services/profile_service.dart'; // [NOWY IMPORT]
import 'package:projekt_grupowy/game_logic/models/game_result.dart';
import 'package:projekt_grupowy/game_logic/models/game_progress.dart';

// Run with: flutter test test/services/offline_and_sync_service_test.dart
// Remember to run: flutter pub run build_runner build

@GenerateMocks([
  Box,
  FirebaseFirestore,
  WriteBatch,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
  FirebaseAuth,
  User,
  ProfileService, // [NOWY MOCK]
])
import 'offline_and_sync_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('OfflineStore & SyncService', () {
    late MockBox resultsBox;
    late MockBox progressBox;
    late MockBox queueBox;
    late OfflineStore store;
    late MockFirebaseFirestore firestore;
    late MockWriteBatch batch;
    late SyncService syncService;
    late MockCollectionReference<Map<String, dynamic>> collectionRef;
    late MockDocumentReference<Map<String, dynamic>> docRef;
    late MockFirebaseAuth auth;
    late MockUser user;
    late MockProfileService profileService; // [NOWA ZMIENNA]

    setUp(() async {
      resultsBox = MockBox();
      progressBox = MockBox();
      queueBox = MockBox();
      store = OfflineStore(resultsBox, progressBox);
      firestore = MockFirebaseFirestore();
      batch = MockWriteBatch();
      collectionRef = MockCollectionReference<Map<String, dynamic>>();
      docRef = MockDocumentReference<Map<String, dynamic>>();
      auth = MockFirebaseAuth();
      user = MockUser();
      profileService = MockProfileService(); // [INICJALIZACJA]

      when(auth.currentUser).thenReturn(user);
      when(firestore.batch()).thenReturn(batch);
      when(firestore.collection(any)).thenReturn(collectionRef);
      when(collectionRef.doc(any)).thenReturn(docRef);
      
      // Mock queue box for persistence
      when(queueBox.get('queue', defaultValue: anyNamed('defaultValue'))).thenReturn([]);
      when(queueBox.put(any, any)).thenAnswer((_) async => null);
      
      // [POPRAWIONY KONSTRUKTOR] - dodano profileService
      syncService = SyncService(store, firestore, auth, queueBox, profileService);
      
      await syncService.start();
      
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
      expect(pending.length, 2); 
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
      // Enqueue the item
      await syncService.enqueueItem('s2', 'result', 'u2');
      when(resultsBox.values).thenReturn([result]);
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshot.exists).thenReturn(false);
      when(docRef.get()).thenAnswer((_) async => mockSnapshot);
      when(docRef.set(any, any)).thenAnswer((_) async => null);
      when(resultsBox.get('s2')).thenReturn(result);
      await syncService.processQueue();
      expect(result.syncPending, false);
      verify(docRef.set(any, any)).called(1);
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
      await syncService.enqueueItem('s3', 'result', 'u3');
      when(resultsBox.values).thenReturn([result]);
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshot.exists).thenReturn(false);
      when(docRef.get()).thenAnswer((_) async => mockSnapshot);
      when(docRef.set(any, any)).thenThrow(Exception('network error'));

      // First sync attempt: should not throw, but syncPending remains true
      await syncService.processQueue();
      expect(result.syncPending, true);

      // Simulate network recovery: next sync attempt succeeds
      await syncService.enqueueItem('s3', 'result', 'u3');
      when(docRef.set(any, any)).thenAnswer((_) async => null);
      when(resultsBox.get('s3')).thenReturn(result);
      await syncService.processQueue();
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
      await syncService.enqueueItem('s4', 'progress', 'u4');
      when(progressBox.values).thenReturn([older, newer]);
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshot.exists).thenReturn(false);
      when(docRef.get()).thenAnswer((_) async => mockSnapshot);
      when(docRef.set(any, any)).thenAnswer((_) async => null);
      when(progressBox.get('s4')).thenReturn(newer);
      await syncService.processQueue();
      expect(newer.syncPending, false);
      expect(older.syncPending, true);
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
      await syncService.enqueueItem('dedupTest', 'result', 'u1');
      when(resultsBox.values).thenReturn([result]);
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshot.exists).thenReturn(true);
      when(docRef.get()).thenAnswer((_) async => mockSnapshot);
      await syncService.processQueue();
      verifyNever(docRef.set(any, any));
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
      await syncService.enqueueItem('conflict1', 'progress', 'u5');
      await syncService.enqueueItem('conflict2', 'progress', 'u6');
      when(progressBox.values).thenReturn([localNewer, localOlder]);
      final remoteOlder = {'lastUpdated': now.subtract(Duration(minutes: 5)).toIso8601String()};
      final remoteNewer = {'lastUpdated': now.toIso8601String()};
      final docRef1 = MockDocumentReference<Map<String, dynamic>>();
      final docRef2 = MockDocumentReference<Map<String, dynamic>>();
      final mockSnapshotNewer = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshotNewer.exists).thenReturn(true);
      when(mockSnapshotNewer.data()).thenReturn(remoteOlder);
      final mockSnapshotOlder = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockSnapshotOlder.exists).thenReturn(true);
      when(mockSnapshotOlder.data()).thenReturn(remoteNewer);
      when(collectionRef.doc('conflict1')).thenReturn(docRef1);
      when(collectionRef.doc('conflict2')).thenReturn(docRef2);
      when(docRef1.get()).thenAnswer((_) async => mockSnapshotNewer);
      when(docRef2.get()).thenAnswer((_) async => mockSnapshotOlder);
      when(docRef1.set(any, any)).thenAnswer((_) async => null);
      when(progressBox.get('conflict1')).thenReturn(localNewer);
      await syncService.processQueue();
      verify(docRef1.set(any, any)).called(1);
      verifyNever(docRef2.set(any, any));
    });
  });
}