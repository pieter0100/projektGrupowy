import 'package:hive/hive.dart';

part 'unlock_requirements.g.dart';

@HiveType(typeId: 5)
class UnlockRequirements {
  @HiveField(0)
  final int minPoints;

  @HiveField(1)
  final String? previousLevelId;

  UnlockRequirements({
    required this.minPoints,
    this.previousLevelId,
  });

  Map<String, dynamic> toJson() {
    return {
      'minPoints': minPoints,
      'previousLevelId': previousLevelId,
    };
  }

  factory UnlockRequirements.fromJson(Map<String, dynamic> json) {
    return UnlockRequirements(
      minPoints: json['minPoints'] as int,
      previousLevelId: json['previousLevelId'] as String?,
    );
  }

  UnlockRequirements copyWith({
    int? minPoints,
    String? previousLevelId,
  }) {
    return UnlockRequirements(
      minPoints: minPoints ?? this.minPoints,
      previousLevelId: previousLevelId ?? this.previousLevelId,
    );
  }

  @override
  String toString() {
    return 'UnlockRequirements(minPoints: $minPoints, previousLevelId: $previousLevelId)';
  }
}