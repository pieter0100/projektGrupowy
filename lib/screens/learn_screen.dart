import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/widgets/learn_widget.dart';
import 'package:projekt_grupowy/widgets/learn_info_widget.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class LearnScreen extends StatelessWidget {
  final String? level;

  const LearnScreen({super.key, this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/level'),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.learnAppBarIcon),
        ),
        title: const Text(
          'Learn',
          style: AppTextStyles.learnTitle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.learnAppBarBackground,
        scrolledUnderElevation: 0.0,
      ),

      body: ListView(
        children: [
          const SizedBox(height: AppSizes.learnTopSpacing),

          Center(child: LearnInfoWidget("× $level")),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LearnWidget("intro"),
              const SizedBox(height: AppSizes.learnLabelSpacing),
              const Text("Intro", style: AppTextStyles.learnLabel),
              const SizedBox(height: AppSizes.learnItemSpacing),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/level/learn/practice?level=$level');
                },
                child: LearnWidget("practice"),
              ),
              const SizedBox(height: AppSizes.learnLabelSpacing),
              const Text("Practice", style: AppTextStyles.learnLabel),
              const SizedBox(height: AppSizes.learnItemSpacing),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/level/learn/exam?level=$level');
                },
                child: LearnWidget("exam"),
              ),
              const SizedBox(height: AppSizes.learnLabelSpacing),
              const Text("Exam", style: AppTextStyles.learnLabel),
              const SizedBox(height: AppSizes.learnItemSpacing),
            ],
          ),
        ],
      ),
    );
  }
}
