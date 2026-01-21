import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../game_logic/local_saves.dart';

import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/widgets/level_widget.dart';

class LevelScreen extends StatelessWidget {
  final int levelsAmount;
  const LevelScreen({super.key, required this.levelsAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Multiply',
              style: TextStyle(fontSize: AppSizes.fontSizeAppBar, color: AppColors.black),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Icon(
              Icons.local_fire_department,
              color: AppColors.Orange,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSizes.spacingTiny),
            const Text(
              '3',
              style: TextStyle(fontSize: AppSizes.fontSizeStats, color: AppColors.Orange),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Icon(Icons.diamond, color: AppColors.Blue, size: AppSizes.iconMedium),
            const SizedBox(width: AppSizes.spacingTiny),
            const Text(
              '1432 XP',
              style: TextStyle(fontSize: AppSizes.fontSizeStats, color: AppColors.Blue),
            ),
          ],
        ),
        backgroundColor: AppColors.appBarBackground,
      ),
      body: ListView.builder(
        itemCount: levelsAmount,
        itemBuilder: (BuildContext context, int index) {
          final String levelId = (index + 1).toString();
          
          final bool unlocked = LocalSaves.isLevelUnlocked("current_user_id", levelId);

          return InkWell(
            onTap: unlocked 
              ? () => context.go('/level/learn?level=$levelId') 
              : null,
            child: LevelWidget(
              textInside: "× $levelId", 
              isLocked: !unlocked,
            ),
          );
        }
      ),
    );
  }
}