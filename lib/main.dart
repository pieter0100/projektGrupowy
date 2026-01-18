import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projekt_grupowy/screens/test.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:projekt_grupowy/controllers/app_session_controller.dart';
import 'app_router.dart'; 
import 'game_logic/local_saves.dart';

// Importujemy LoadingScreen (lub definiujemy go, jeśli jest w routerze)
// Zakładam, że jest w routerze lub osobnym pliku. Tu dla pewności import:
// import 'app_router.dart' show LoadingScreen; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalSaves.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Inicjalizacja kontrolera
  final sessionController = await AppSessionController.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionController),
        Provider.value(value: sessionController.syncService),
        Provider.value(value: sessionController.store),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Używamy Consumer, aby "MyApp" reagował na zmiany w AppSessionController
    return Consumer<AppSessionController>(
      builder: (context, controller, child) {
        
        // --- 1. OBSŁUGA BOOTSTRAPPING (SPINNER) ---
        // Specyfikacja wymaga, aby spinner był widoczny podczas bootstrappingu.
        // Możemy to wymusić na poziomie samej aplikacji, zanim router w ogóle ruszy.
        if (controller.state == SessionState.bootstrapping) {
          return MaterialApp(
            // home: const LoadingScreen(), // Bezpośrednio pokazujemy LoadingScreen
            home: const TestDashboardScreen(), // Tymczasowo pokazujemy TestDashboardScreen
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
          );
        }

        // --- 2. OBSŁUGA ROUTINGU DLA POZOSTAŁYCH STANÓW ---
        // Tworzymy router dynamicznie w oparciu o aktualny stan kontrolera.
        // Dzięki temu 'refreshListenable' wewnątrz routera ma zawsze świeży obiekt.
        final router = createAppRouter(controller);

        return MaterialApp.router(
          routerConfig: router,
          title: 'GoRouter Bottom Nav',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
        );
      },
    );
  }
}