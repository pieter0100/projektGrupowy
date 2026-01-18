import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart'; // Potrzebne do typu GoRouter
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:projekt_grupowy/controllers/app_session_controller.dart';
import 'app_router.dart'; // Upewnij się, że tu jest funkcja createAppRouter
import 'game_logic/local_saves.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and all adapters
  await LocalSaves.init();
  
  // Initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Tworzymy kontroler (Logika sesji)
  final sessionController = await AppSessionController.create();

  // 2. Tworzymy router, przekazując mu kontroler (Logika przekierowań)
  final router = createAppRouter(sessionController);

  runApp(
    MultiProvider(
      providers: [
        // Główny kontroler
        ChangeNotifierProvider.value(value: sessionController),

        // Serwisy zależne (opcjonalnie, jeśli są potrzebne w drzewie widgetów)
        Provider.value(value: sessionController.syncService),
        Provider.value(value: sessionController.store),
      ],
      // 3. Przekazujemy skonfigurowany router do MyApp
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  // Dodajemy parametr router do konstruktora
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Używamy przekazanego routera
      title: 'GoRouter Bottom Nav',
      theme: ThemeData(
        // Możesz dodać swój motyw tutaj
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}