import 'package:hive/hive.dart';
import 'unlock_requirements.dart';

part '../generated/level.g.dart';

@HiveType(typeId: 6)
class Rewards {
  @HiveField(0)
  final int points;

  Rewards({required this.points});

  Map<String, dynamic> toJson() {
    return {'points': points};
  }

  factory Rewards.fromJson(Map<String, dynamic> json) {
    return Rewards(points: json['points'] as int);
  }

  Rewards copyWith({int? points}) {
    return Rewards(points: points ?? this.points);
  }

  @override
  String toString() {
    return 'Rewards(points: $points)';
  }
}

@HiveType(typeId: 7)
class LevelInfo {
  @HiveField(0)
  final String levelId;

  @HiveField(1)
  final int levelNumber;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final UnlockRequirements unlockRequirements;

  @HiveField(5)
  final Rewards rewards;

  @HiveField(6)
  final bool isRevision;

  LevelInfo({
    required this.levelId,
    required this.levelNumber,
    required this.name,
    required this.description,
    required this.unlockRequirements,
    required this.rewards,
    required this.isRevision,
  });

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'levelNumber': levelNumber,
      'name': name,
      'description': description,
      'unlockRequirements': unlockRequirements.toJson(),
      'rewards': rewards.toJson(),
      'isRevision': isRevision,
    };
  }

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      levelId: json['levelId'] as String,
      levelNumber: json['levelNumber'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      unlockRequirements: UnlockRequirements.fromJson(
          json['unlockRequirements'] as Map<String, dynamic>),
      rewards: Rewards.fromJson(json['rewards'] as Map<String, dynamic>),
      isRevision: json['isRevision'] as bool,
    );
  }

  LevelInfo copyWith({
    String? levelId,
    int? levelNumber,
    String? name,
    String? description,
    UnlockRequirements? unlockRequirements,
    Rewards? rewards,
    bool? isRevision,
  }) {
    return LevelInfo(
      levelId: levelId ?? this.levelId,
      levelNumber: levelNumber ?? this.levelNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      unlockRequirements: unlockRequirements ?? this.unlockRequirements,
      rewards: rewards ?? this.rewards,
      isRevision: isRevision ?? this.isRevision,
    );
  }

  @override
  String toString() {
    return 'LevelInfo(levelId: $levelId, levelNumber: $levelNumber, name: $name, description: $description, unlockRequirements: $unlockRequirements, rewards: $rewards, isRevision: $isRevision)';
  }
}