import 'package:flutter/material.dart';
import 'app_router.dart';
import 'game_logic/local_saves.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and all adapters
  await LocalSaves.init();

  // Run tests
  await LocalSaves.testAllClasses();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}


