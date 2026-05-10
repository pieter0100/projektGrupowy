// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StageResultAdapter extends TypeAdapter<StageResult> {
  @override
  final int typeId = 21;

  @override
  StageResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StageResult(
      isCorrect: fields[0] as bool,
      skipped: fields[1] as bool,
      answerTime: fields[2] as int?,
      userAnswer: fields[3] as dynamic,
      points: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StageResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isCorrect)
      ..writeByte(1)
      ..write(obj.skipped)
      ..writeByte(2)
      ..write(obj.answerTime)
      ..writeByte(3)
      ..write(obj.userAnswer)
      ..writeByte(4)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StageResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
