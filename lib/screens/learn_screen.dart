import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/widgets/learn_widget.dart';
import 'package:projekt_grupowy/widgets/learn_info_widget.dart';

class LearnScreen extends StatelessWidget {
  final String? level;

  const LearnScreen({super.key, this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level'),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Learn'),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        scrolledUnderElevation: 0.0,
      ),
      body: ListView(
        children: [
          SizedBox(height: AppSizes.screenPaddingTop),
          Center(child: LearnInfoWidget("× $level")),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LearnWidget("intro"),
              SizedBox(height: AppSizes.spacingSmall),
              Text("Intro", style: TextStyle(fontSize: AppSizes.settingsFontSize)),
              SizedBox(height: AppSizes.spacingMedium),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  context.go('/level/learn/practice?level=$level');
                },
                child: LearnWidget("practice"),
              ),
              SizedBox(height: AppSizes.spacingSmall),
              Text("Practice", style: TextStyle(fontSize: AppSizes.settingsFontSize)),
              SizedBox(height: AppSizes.spacingMedium),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LearnWidget("exam"),
              SizedBox(height: AppSizes.spacingSmall),
              Text("Exam", style: TextStyle(fontSize: AppSizes.settingsFontSize)),
              SizedBox(height: AppSizes.spacingMedium),
            ],
          ),
        ],
      ),
    );
  }
}
