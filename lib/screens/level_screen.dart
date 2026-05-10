import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:projekt_grupowy/game_logic/local_saves.dart';
import 'package:projekt_grupowy/services/auth_service.dart';

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
  bool _debugUnlockAll = false;
  String? get userId => auth.FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _initializeDataIfNeeded();
  }

  Future<void> _initializeDataIfNeeded() async {
    final uid = userId;
    if (uid == null) return;
    
    // First, try to fetch from Firestore if not in Hive
    if (LocalSaves.getUser(uid) == null) {
      await AuthService().syncUserFromFirestore(uid);
    }
    
    // Check again after sync attempt
    if (LocalSaves.getUser(uid) == null) {
      final newUser = User(
        userId: uid,
        stats: UserStats(
          totalGamesPlayed: 0,
          totalPoints: 0,
          currentStreak: 0,
          lastPlayedAt: DateTime.now(),
        ),
        profile: UserProfile(displayName: "Player", age: 10, nick: "Player"),
      );
      await LocalSaves.saveUser(newUser);
    }
    
    // Refresh the view after ensuring user data exists
    if (mounted) setState(() {});

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
    final uid = userId;
    final user = uid != null ? LocalSaves.getUser(uid) : null;
    final int streak = user?.stats.currentStreak ?? 0;
    final int totalPoints = user?.stats.totalPoints ?? 0;

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
            Text(
              '$streak',
              style: const TextStyle(
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
            Text(
              '$totalPoints XP',
              style: const TextStyle(
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
          final uid = userId;
          final bool isUnlockedByProgress = uid != null ? LocalSaves.isLevelUnlocked(uid, levelId) : false;
          final bool unlocked = _debugUnlockAll || isUnlockedByProgress;

          return InkWell(
            onTap: unlocked
                ? () => context.go('/level/learn?level=$levelId')
                : null,
            child: LevelWidget(textInside: "× $levelId", isLocked: !unlocked),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _debugUnlockAll = !_debugUnlockAll;
          });
        },
        backgroundColor: Colors.redAccent,
        tooltip: 'Debug: Unlock All Levels',
        child: Icon(_debugUnlockAll ? Icons.lock_open : Icons.bug_report),
      ),
    );
  }
}
