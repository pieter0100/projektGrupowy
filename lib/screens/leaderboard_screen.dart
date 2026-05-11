import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardUser {
  final String uid;
  final String nick;
  final int totalPoints;
  final int streak;
  final int gamesPlayed;

  LeaderboardUser({
    required this.uid,
    required this.nick,
    required this.totalPoints,
    required this.streak,
    required this.gamesPlayed,
  });

  factory LeaderboardUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final profile = data['profile'] as Map<String, dynamic>? ?? {};
    final stats = data['stats'] as Map<String, dynamic>? ?? {};

    return LeaderboardUser(
      uid: doc.id,
      nick: profile['nick'] as String? ?? 'Nieznany',
      totalPoints: stats['totalPoints'] as int? ?? 0,
      streak: stats['currentStreak'] as int? ?? 0,
      gamesPlayed: stats['totalGamesPlayed'] as int? ?? 0,
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text(
          'Leader board',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('stats.currentStreak', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Brak danych do wyświetlenia.'));
          }

          final users = snapshot.data!.docs
              .map((doc) => LeaderboardUser.fromDocument(doc))
              .toList();

          // Znajdź statystyki aktualnego użytkownika do górnego paska
          LeaderboardUser? currentUserStats;
          try {
            currentUserStats = users.firstWhere((u) => u.uid == currentUserUid);
          } catch (e) {
            // Użytkownik nie znalazł się w top 50, statystyki będą 0
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              // User Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(Icons.local_fire_department, Colors.orange, '${currentUserStats?.streak ?? 0}'),
                  _buildStatItem(Icons.inventory_2, Colors.teal, '${currentUserStats?.totalPoints ?? 0} XP'),
                  _buildStatItem(Icons.emoji_events, Colors.amber, '${currentUserStats?.gamesPlayed ?? 0}'), // L. gier zamiast 8/10
                ],
              ),
              const SizedBox(height: 30),
              
                    // Podium
                  if (users.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 2nd Place
                        if (users.length > 1)
                          _buildPodiumAvatar(users[1].nick, users[1].streak, 2, Colors.teal.shade300, 45, const Color(0xFFF2D1A1)),
                        if (users.length <= 1) const SizedBox(width: 90),

                        const SizedBox(width: 10),

                        // 1st Place
                        if (users.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildPodiumAvatar(users[0].nick, users[0].streak, 1, Colors.teal.shade400, 55, const Color(0xFFB1C4D9)),
                          ),

                        const SizedBox(width: 10),

                        // 3rd Place
                        if (users.length > 2)
                          _buildPodiumAvatar(users[2].nick, users[2].streak, 3, Colors.teal.shade300, 45, const Color(0xFFE3CBA8)),
                        if (users.length <= 2) const SizedBox(width: 90),
                      ],
                    ),
                  const SizedBox(height: 30),
                  
                  // List of other users
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: users.length > 3 ? users.length - 3 : 0,
                      itemBuilder: (context, index) {
                        final rank = index + 4; // Zaczynamy od 4. miejsca
                        final user = users[index + 3];
                        final isCurrentUser = user.uid == currentUserUid;

                        // Kilka kolorów teł awatarów dla różnorodności
                        final bgColors = [
                          const Color(0xFFF2A1A1), 
                          const Color(0xFFE2C4E5), 
                          const Color(0xFFA1C4F2), 
                          const Color(0xFFA1E2A1)
                        ];
                        final avatarBgColor = bgColors[index % bgColors.length];

                        return _buildLeaderboardRow(rank, user.nick, user.streak, isCurrentUser, avatarBgColor);
                      },
                    ),
                  ),

            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color == Colors.teal ? Colors.teal : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumAvatar(String name, int score, int rank, Color rankColor, double radius, Color avatarBgColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topLeft,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: avatarBgColor,
              child: Icon(Icons.person, size: radius * 1.2, color: Colors.white),
            ),
            Container(
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(6),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
            const SizedBox(width: 2),
            Text(
              '$score',
              style: const TextStyle(fontSize: 14, color: Colors.orange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, int score, bool isCurrentUser, Color avatarBgColor) {
    final bool shouldHighlight = isCurrentUser && rank > 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: shouldHighlight ? const Color(0xFFdbe8e8) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: shouldHighlight ? Colors.transparent : const Color(0xFFE8E5DF),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarBgColor,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
