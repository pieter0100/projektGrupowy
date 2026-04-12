import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

// Importy Twoich klas (dostosuj, jeśli nazwy folderów są inne)
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/level/level_progress.dart';
import 'package:projekt_grupowy/services/auth_service.dart';
import '../controllers/app_session_controller.dart';

// WAŻNE: Alias dla Twojego modelu User, żeby nie mylił się z Firebase User
import '../models/user/user.dart' as model; 

class TestDashboardScreen extends StatefulWidget {
  const TestDashboardScreen({super.key});

  @override
  State<TestDashboardScreen> createState() => _TestDashboardScreenState();
}

class _TestDashboardScreenState extends State<TestDashboardScreen> {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,      // Ukrywa nazwy metod (czystsza konsola)
      errorMethodCount: 8, // Pokazuje ścieżkę błędu tylko gdy coś wybuchnie
      lineLength: 80,      // Długość linii
      colors: true,        // Włącza kolory (np. czerwony dla błędów)
      printEmojis: true,   // Dodaje emoji do logów
    ),
  );
  
  // --- Metoda Logowania ---
  Future<void> _quickLogin() async {
    const testEmail = "test@test.com";
    const testPassword = "Password1!";
    final testUsername = "TestUser_${Random().nextInt(9999)}";

    try {
      logger.i("Próba logowania jako $testEmail...");
      
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        logger.i("Zalogowano pomyślnie!");
      } on FirebaseAuthException catch (e) {
        logger.w("Błąd logowania: ${e.code}. Próba rejestracji...");
        
        if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
          AuthService authService = AuthService();
          logger.i("Rejestracja nowego usera: $testUsername...");
          
          await authService.register(testEmail, testPassword, testUsername);
          logger.i("Zarejestrowano i zalogowano!");
        } else {
          rethrow; 
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sukces! Rozpoczynam Bootstrap...'))
        );
      }
    } catch (e, stackTrace) {
      // Przekazanie 'e' jako error i dodanie 'stackTrace' pozwala loggerowi 
      // pięknie wyrysować ścieżkę błędu w konsoli!
      logger.e("Wystąpił błąd podczas logowania/rejestracji", error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSessionController>();
    final syncService = session.syncService;
    
    // Otwieramy boxy
    final progressBox = Hive.box<LevelProgress>(LocalSaves.levelProgressBoxName);
    // Używamy aliasu model.User, żeby uniknąć błędu "Ambiguous import"
    final usersBox = Hive.box<model.User>(LocalSaves.usersBoxName); 
    
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = session.state == SessionState.authenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First DEBUG'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => session.signOut(),
            tooltip: 'Wyloguj',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- SEKCJA STATUSU ---
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                children: [
                  Text('User UID: ${currentUser?.uid ?? "Brak"}', 
                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 10),
                  
                  // 1. DANE Z FIRESTORE (CHMURA)
                  if (currentUser != null) 
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("Ładowanie z chmury...");
                        if (!snapshot.data!.exists) return const Text("Brak w chmurze");

                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        final profile = data['profile'] as Map<String, dynamic>? ?? {};
                        final stats = data['stats'] as Map<String, dynamic>? ?? {};

                        return _buildInfoCard(
                          title: "FIRESTORE DATA (Chmura)",
                          color: Colors.blue[50]!,
                          rows: [
                            _dataRow("Nick", profile['displayName'] ?? '-'),
                            _dataRow("Wiek", profile['age']?.toString() ?? '-'),
                            _dataRow("Punkty", stats['totalPoints']?.toString() ?? '0'),
                            _dataRow("Gry", stats['totalGamesPlayed']?.toString() ?? '0'),
                            _dataRow("Streak", stats['currentStreak']?.toString() ?? '0'),
                            _dataRow("Ostatnia gra", stats['lastPlayedAt']?.toString() ?? '-'),
                          ]
                        );
                      },
                    ),

                  const SizedBox(height: 8),

                  // 2. DANE Z HIVE (LOKALNE - CACHE)
                  if (currentUser != null)
                    ValueListenableBuilder(
                      valueListenable: usersBox.listenable(),
                      builder: (context, Box<model.User> box, _) {
                        final localUser = box.get(currentUser.uid);

                        if (localUser == null) {
                          return _buildInfoCard(
                            title: "HIVE DATA (Cache)",
                            color: Colors.red[50]!,
                            rows: [const Center(child: Text("Brak danych lokalnych (zrób Bootstrap!)"))]
                          );
                        }

                        return _buildInfoCard(
                          title: "HIVE DATA (Offline Cache)",
                          color: Colors.purple[50]!,
                          rows: [
                            // Odwołujemy się do pól Twojego modelu User
                            _dataRow("Nick", localUser.profile.displayName ?? '-'),
                            _dataRow("Wiek", localUser.profile.age?.toString() ?? '-'),
                            _dataRow("Punkty", localUser.stats.totalPoints.toString()),
                            _dataRow("Gry", localUser.stats.totalGamesPlayed.toString()),
                            _dataRow("Streak", localUser.stats.currentStreak.toString()),
                            // Zakładam, że lastPlayedAt to String lub DateTime (dostosuj toString)
                            _dataRow("Ostatnia gra", localUser.stats.lastPlayedAt?.toString() ?? '-'),
                          ]
                        );
                      },
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Statusy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildChip('Stan: ${session.state.name.split('.').last}', 
                        isLoggedIn ? Colors.green[100]! : Colors.red[100]!),
                      _buildChip('Kolejka: ${syncService.getQueue().length}', 
                        syncService.getQueue().isEmpty ? Colors.green[100]! : Colors.orange[100]!),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Przyciski (Bez "Dodaj")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Login'),
                        onPressed: isLoggedIn ? null : _quickLogin,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync'),
                        onPressed: () => syncService.triggerSync(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(thickness: 2),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("HISTORIA GIER (LevelProgress):", style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // --- LISTA LEVEL PROGRESS Z HIVE ---
            SizedBox(
              height: 300, 
              child: ValueListenableBuilder(
                valueListenable: progressBox.listenable(),
                builder: (context, Box<LevelProgress> box, _) {
                  if (box.isEmpty) return const Center(child: Text("Brak wyników gier."));
                  
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final key = box.keyAt(index);
                      final progress = box.getAt(index);
                      final bool isPending = (progress as dynamic).syncPending == true;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            isPending ? Icons.cloud_upload : Icons.cloud_done,
                            color: isPending ? Colors.orange : Colors.green,
                          ),
                          title: Text("Klucz: $key"),
                          // Dostosuj wyświetlanie do swojego modelu LevelProgress
                          subtitle: Text("Level: ${progress?.levelId} | Pkt: ${progress?.score}"), 
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => box.delete(key),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Pomocnicze Widgety ---

  Widget _buildInfoCard({required String title, required Color color, required List<Widget> rows}) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(label: Text(label), backgroundColor: color);
  }
}