import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../game_logic/local_saves.dart';

import 'package:projekt_grupowy/utils/constants.dart';
import 'package:projekt_grupowy/widgets/level_widget.dart';
// Imports for initalizing user data
import 'package:projekt_grupowy/models/user/user.dart';
import 'package:projekt_grupowy/models/user/user_stats.dart';
import 'package:projekt_grupowy/models/user/user_profile.dart';
import 'package:projekt_grupowy/models/level/level.dart';
import 'package:projekt_grupowy/models/level/unlock_requirements.dart';

class LevelScreen extends StatefulWidget {
  final int levelsAmount;
  const LevelScreen({super.key, required this.levelsAmount});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final String userId = "user1";

  @override
  void initState() {
    super.initState();
    _initializeDataIfNeeded();
  }

  Future<void> _initializeDataIfNeeded() async {
    if (LocalSaves.getUser(userId) == null) {
      final newUser = User(
        userId: userId,
        stats: UserStats(
          totalGamesPlayed: 0,
          totalPoints: 0,
          currentStreak: 0,
          lastPlayedAt: DateTime.now(),
        ),
        profile: UserProfile(displayName: "Player 1", age: 10),
      );
      await LocalSaves.saveUser(newUser);
    }

    if (LocalSaves.getLevel('2') == null) {
      for (int i = 1; i <= widget.levelsAmount; i++) {
        final levelId = i.toString();
        final prevLevelId = i > 1 ? (i - 1).toString() : null;

        final levelInfo = LevelInfo(
          levelId: levelId,
          levelNumber: i,
          name: "Level $i",
          description: "Nauka mnożenia przez $i",
          unlockRequirements: UnlockRequirements(
            minPoints: 0,
            previousLevelId: prevLevelId,
          ),
          rewards: Rewards(points: 100),
          isRevision: false,
        );
        await LocalSaves.saveLevel(levelInfo);
      }
      // Refresh the view after saving data
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Multiply',
              style: TextStyle(
                fontSize: AppSizes.fontSizeAppBar,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Icon(
              Icons.local_fire_department,
              color: AppColors.orange,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSizes.spacingTiny),
            const Text(
              '3',
              style: TextStyle(
                fontSize: AppSizes.fontSizeStats,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Icon(
              Icons.diamond,
              color: AppColors.blue,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSizes.spacingTiny),
            const Text(
              '1432 XP',
              style: TextStyle(
                fontSize: AppSizes.fontSizeStats,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.appBarBackground,
      ),
      body: ListView.builder(
        itemCount: widget.levelsAmount,
        itemBuilder: (BuildContext context, int index) {
          final String levelId = (index + 1).toString();

          final bool unlocked = LocalSaves.isLevelUnlocked("user1", levelId);

          return InkWell(
            onTap: unlocked
                ? () => context.go('/level/learn?level=$levelId')
                : null,
            child: LevelWidget(textInside: "× $levelId", isLocked: !unlocked),
          );
        },
      ),
    );
  }
}
