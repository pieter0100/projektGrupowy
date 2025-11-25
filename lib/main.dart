// main.dart
import 'package:flutter/material.dart';
import 'package:projekt_grupowy/app_router.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'GoRouter Bottom Nav',
    );
  }
}