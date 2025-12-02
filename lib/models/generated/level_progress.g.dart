// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../level/level_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LevelProgressAdapter extends TypeAdapter<LevelProgress> {
  @override
  final int typeId = 4;

  @override
  LevelProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LevelProgress(
      levelId: fields[0] as String,
      bestScore: fields[1] as int,
      bestTimeSeconds: fields[2] as int,
      attempts: fields[3] as int,
      completed: fields[4] as bool,
      firstCompletedAt: fields[5] as DateTime?,
      lastPlayedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LevelProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.levelId)
      ..writeByte(1)
      ..write(obj.bestScore)
      ..writeByte(2)
      ..write(obj.bestTimeSeconds)
      ..writeByte(3)
      ..write(obj.attempts)
      ..writeByte(4)
      ..write(obj.completed)
      ..writeByte(5)
      ..write(obj.firstCompletedAt)
      ..writeByte(6)
      ..write(obj.lastPlayedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
