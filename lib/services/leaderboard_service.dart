import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  static Future<int?> getUserRank(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('stats.currentStreak', descending: true)
          .get();

      final users = snapshot.docs;
      final userIndex = users.indexWhere((doc) => doc.id == userId);

      if (userIndex != -1) {
        return userIndex + 1;
      }
      return null;
    } catch (e) {
      print('Error fetching user rank: $e');
      return null;
    }
  }
}
