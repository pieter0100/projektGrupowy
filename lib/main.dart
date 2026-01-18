import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projekt_grupowy/controllers/app_session_controller.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'app_router.dart';
import 'game_logic/local_saves.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and all adapters
  await LocalSaves.init();
  // Run tests
  // await LocalSaves.testAllClasses();

  // Initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final sessionController = await AppSessionController.create();

  runApp(
    MultiProvider(
      providers: [
        // Główny kontroler
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
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'GoRouter Bottom Nav',
    );
  }
}
