// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../level/unlock_requirements.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnlockRequirementsAdapter extends TypeAdapter<UnlockRequirements> {
  @override
  final int typeId = 5;

  @override
  UnlockRequirements read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnlockRequirements(
      minPoints: fields[0] as int,
      previousLevelId: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UnlockRequirements obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.minPoints)
      ..writeByte(1)
      ..write(obj.previousLevelId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlockRequirementsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
