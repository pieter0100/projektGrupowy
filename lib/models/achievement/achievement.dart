import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 10)
class Achievement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int xpValue;

  @HiveField(4)
  final DateTime dateAchieved;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.xpValue,
    required this.dateAchieved,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xpValue': xpValue,
      'dateAchieved': dateAchieved.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      xpValue: json['xpValue'] as int,
      dateAchieved: DateTime.parse(json['dateAchieved'] as String),
    );
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    int? xpValue,
    DateTime? dateAchieved,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpValue: xpValue ?? this.xpValue,
      dateAchieved: dateAchieved ?? this.dateAchieved,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, xpValue: $xpValue)';
  }
}
