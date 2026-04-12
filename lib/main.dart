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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Multiplication Game',
      debugShowCheckedModeBanner: false,
    );
  }
}