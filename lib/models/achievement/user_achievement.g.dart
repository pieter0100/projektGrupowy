// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAchievementAdapter extends TypeAdapter<UserAchievement> {
  @override
  final int typeId = 20;

  @override
  UserAchievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAchievement(
      achievementId: fields[0] as String,
      earnedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserAchievement obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.achievementId)
      ..writeByte(1)
      ..write(obj.earnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
