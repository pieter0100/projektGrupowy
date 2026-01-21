// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../level/level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardsAdapter extends TypeAdapter<Rewards> {
  @override
  final int typeId = 6;

  @override
  Rewards read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rewards(
      points: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Rewards obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LevelInfoAdapter extends TypeAdapter<LevelInfo> {
  @override
  final int typeId = 7;

  @override
  LevelInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LevelInfo(
      levelId: fields[0] as String,
      levelNumber: fields[1] as int,
      name: fields[2] as String,
      description: fields[3] as String,
      unlockRequirements: fields[4] as UnlockRequirements,
      rewards: fields[5] as Rewards,
      isRevision: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LevelInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.levelId)
      ..writeByte(1)
      ..write(obj.levelNumber)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.unlockRequirements)
      ..writeByte(5)
      ..write(obj.rewards)
      ..writeByte(6)
      ..write(obj.isRevision);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
