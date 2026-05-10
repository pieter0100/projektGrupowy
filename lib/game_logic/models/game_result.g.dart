// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameResultAdapter extends TypeAdapter<GameResult> {
  @override
  final int typeId = 20;

  @override
  GameResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameResult(
      sessionId: fields[0] as String,
      uid: fields[1] as String,
      timestamp: fields[2] as DateTime,
      stageResults: (fields[3] as List).cast<StageResult>(),
      score: fields[4] as int,
      gameType: fields[5] as String,
      syncPending: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GameResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.stageResults)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.gameType)
      ..writeByte(6)
      ..write(obj.syncPending);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
