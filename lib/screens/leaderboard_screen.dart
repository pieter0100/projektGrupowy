import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(Icons.local_fire_department, Colors.orange, '3'),
                _buildStatItem(Icons.inventory_2, Colors.teal, '1432 XP'),
                _buildStatItem(Icons.emoji_events, Colors.amber, '8/10'),
              ],
            ),
            const SizedBox(height: 30),
            // Podium
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd Place
                _buildPodiumAvatar('Jenna', 12, 2, Colors.teal.shade300, 45, const Color(0xFFF2D1A1)),
                const SizedBox(width: 10),
                // 1st Place
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildPodiumAvatar('Anna', 13, 1, Colors.teal.shade400, 55, const Color(0xFFB1C4D9)),
                ),
                const SizedBox(width: 10),
                // 3rd Place
                _buildPodiumAvatar('Jack', 11, 3, Colors.teal.shade300, 45, const Color(0xFFE3CBA8)),
              ],
            ),
            const SizedBox(height: 30),
            // List of other users
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildLeaderboardRow(4, 'Peter', 10, false, const Color(0xFFF2A1A1)),
                  _buildLeaderboardRow(5, 'Hannah', 9, false, const Color(0xFFE2C4E5)),
                  _buildLeaderboardRow(6, 'Ron', 8, false, const Color(0xFFA1C4F2)),
                  _buildLeaderboardRow(7, 'Nidhi', 7, true, const Color(0xFFE2D1A1)), // Highlighted
                  _buildLeaderboardRow(8, 'William', 6, false, const Color(0xFFA1E2A1)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFD4E5E3) : const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser ? Colors.transparent : const Color(0xFFE8E5DF),
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
