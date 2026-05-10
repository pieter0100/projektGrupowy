import 'package:flutter/material.dart';
import 'package:projekt_grupowy/widgets/profile_stats.dart';
// Adjust these imports to match your project structure:
import '../game_logic/local_saves.dart';
import 'package:projekt_grupowy/models/user/user.dart';
// If using Firebase Auth to get the current user's ID:
import 'package:firebase_auth/firebase_auth.dart' as auth;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Assuming you're using Firebase Auth to get the ID.
      // If you are hardcoding or using another method, adjust this.
      final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId != null) {
        // Retrieve the user from Hive
        final user = LocalSaves.getUser(currentUserId);
        
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reload data every time this widget is built (important for navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: const Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Added scroll view for smaller screens
              child: Column(
                children: [
                  ProfileHeader(user: _currentUser),
                  StatisticsSection(user: _currentUser),
                  const SizedBox(height: 20),
                  const InviteFriendsCard(),
                ],
              ),
            ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final User? user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Extract data with fallbacks
    final displayName = user?.profile.displayName ?? user?.profile.nick ?? 'Unknown User';
    final nick = user?.profile.nick ?? 'unknown';
    final nickName = '@$nick'; 
    // Format the date if it exists, otherwise placeholder
    final joinedDate = user?.stats.lastPlayedAt != null 
        ? '${user!.stats.lastPlayedAt!.day}/${user!.stats.lastPlayedAt!.month}/${user!.stats.lastPlayedAt!.year}' 
        : 'Unknown Date';

    return Container(
      padding: const EdgeInsets.only(
        top: 25.0,
        bottom: 15.0,
        left: 10.0,
        right: 10.0,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x33000000), width: 3.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
              Text(
                nickName,
                style: const TextStyle(fontSize: 20.0, color: Color(0x88000000)),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    size: 16.0,
                    color: Color(0x88000000),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'Joined $joinedDate',
                    style: const TextStyle(fontSize: 15.0, height: 2.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 30.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatisticsSection extends StatelessWidget {
  final User? user;

  const StatisticsSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Extract stats with fallbacks
    final dayStreak = user?.stats.currentStreak.toString() ?? '0';
    final totalPoints = user?.stats.totalPoints.toString() ?? '0';
    // For achievements and leaderboard, you'll need logic to calculate them later.
    // For now, using totalGamesPlayed or placeholders.
    final gamesPlayed = user?.stats.totalGamesPlayed.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.only(
        top: 15.0,
        bottom: 0.0,
        left: 10.0,
        right: 10.0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30.0),
              Column(children: const [SizedBox(width: 190)]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  StatisticBox(witchBox: 'dayStreak', value: dayStreak),
                  const SizedBox(height: 15.0),
                  StatisticBox(witchBox: 'achievements', value: gamesPlayed), // Placeholder for achievements
                ],
              ),
              const SizedBox(width: 15.0),
              Column(
                children: [
                  StatisticBox(witchBox: 'totalXP', value: totalPoints),
                  const SizedBox(height: 15.0),
                  StatisticBox(witchBox: 'leaderBoard', value: 'N/A'), // Placeholder for rank
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InviteFriendsCard extends StatelessWidget {
  const InviteFriendsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0x33000000);
    const Color buttonColor = Color(0xFF02A1FB);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 80,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite your friends',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Tell your friends it’s free and fun to learn on Multiply app!',
                      style: TextStyle(fontSize: 16.0, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            height: 47.0,
            child: ElevatedButton(
              onPressed: () {
                print("Invite friends clicked");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0x8802A1FB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: const Text(
                'INVITE FRIENDS',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
