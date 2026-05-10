import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:projekt_grupowy/controllers/app_session_controller.dart';
import 'app_router.dart';
import 'game_logic/local_saves.dart';
import 'services/achivemnt_seeder.dart';


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


  // ODkomentuj poniższą linię, uruchom aplikację RAZ, a potem ją usuń/zakomentuj
  // await AchievementSeeder.seed(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSessionController>(
      future: AppSessionController.create(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        final sessionController = snapshot.data!;

        return ChangeNotifierProvider<AppSessionController>.value(
          value: sessionController,
          child: MaterialApp.router(
            routerConfig: appRouter,
            title: 'Multiplication Game',
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}