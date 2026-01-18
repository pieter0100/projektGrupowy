import 'package:flutter/material.dart';

import 'app_router.dart';
import 'game_logic/local_saves.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalSaves.init();
  await LocalSaves.testAllClasses();

  runApp(const MyApp());
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
