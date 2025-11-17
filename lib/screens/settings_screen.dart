import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/widgets/settings_data_widget.dart';
import 'package:projekt_grupowy/widgets/settings_delete_widget.dart';

class SettingsScreen extends StatelessWidget{
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level'),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Settings screen'),
        backgroundColor: Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          SizedBox(height: 40),
          Center(
            child: SettingsDataWidget("Personal data"),
          ),
          SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SettingsDeleteWidget("Delete account"),
              SizedBox(height: 8),
            ],
          ),
        ],
        
      ),
    );
  }
}