// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaderboardAdapter extends TypeAdapter<Leaderboard> {
  @override
  final int typeId = 9;

  @override
  Leaderboard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Leaderboard(
      entries: (fields[0] as List).cast<LeaderboardEntry>(),
      lastUpdated: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Leaderboard obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.entries)
      ..writeByte(1)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
