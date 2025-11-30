import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard page'),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Center(
        child: Text('Leaderboard page')
      ),
    );
  }
}
