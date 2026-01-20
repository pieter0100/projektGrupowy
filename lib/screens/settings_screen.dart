import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/widgets/settings_data_widget.dart';
import 'package:projekt_grupowy/widgets/settings_delete_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level'),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          SizedBox(height: AppSizes.screenPaddingTop),
          Center(child: SettingsDataWidget("Personal data")),
          SizedBox(height: AppSizes.screenPaddingTop),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SettingsDeleteWidget("Delete account"),
              SizedBox(height: AppSizes.spacingSmall),
            ],
          ),
        ],
      ),
    );
  }
}
