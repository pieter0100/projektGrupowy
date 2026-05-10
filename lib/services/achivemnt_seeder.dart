import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementSeeder {
  static Future<void> seed() async {
    final firestore = FirebaseFirestore.instance;
    
    final List<Map<String, dynamic>> achievements = [];

    // 1. Automatyczne generowanie dla poziomów 1-10
    for (int i = 1; i <= 10; i++) {
      achievements.add({
        'id': 'multiply_${i}_complete',
        'title': 'Mistrz mnożenia przez $i',
        'description': 'Ukończono naukę i test dla liczby $i.',
        'iconUrl': 'assets/icons/level_$i.png',
        'points': 100,
      });
    }

    // 2. Dodatkowe osiągnięcia specjalne
    achievements.addAll([
      {
        'id': 'streak_3_days',
        'title': 'Regularny uczeń',
        'description': 'Ucz się przez 3 dni z rzędu.',
        'iconUrl': 'assets/icons/fire.png',
        'points': 250,
      },
      {
        'id': 'exam_master',
        'title': 'Mistrz Egzaminów',
        'description': 'Zdobądź 100% punktów w dowolnym egzaminie.',
        'iconUrl': 'assets/icons/medal.png',
        'points': 500,
      },
    ]);

    final batch = firestore.batch();

    for (var data in achievements) {
      // Używam "Achievements" tak jak w Twojej ostatniej edycji
      final docRef = firestore.collection('Achievements').doc(data['id']);
      batch.set(docRef, data);
    }

    await batch.commit();
    print('✅ Pomyślnie dodano ${achievements.length} osiągnięć do bazy Firestore!');
  }
}
