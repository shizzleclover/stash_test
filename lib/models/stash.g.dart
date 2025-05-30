// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stash.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StashAdapter extends TypeAdapter<Stash> {
  @override
  final int typeId = 0;

  @override
  Stash read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Stash(
      id: fields[0] as String,
      name: fields[1] as String,
      currentAmount: fields[2] as double,
      targetAmount: fields[3] as double,
      category: fields[4] as String,
      createdDate: fields[5] as DateTime,
      contributions: (fields[6] as List?)?.cast<Contribution>(),
    );
  }

  @override
  void write(BinaryWriter writer, Stash obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.currentAmount)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.createdDate)
      ..writeByte(6)
      ..write(obj.contributions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StashAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContributionAdapter extends TypeAdapter<Contribution> {
  @override
  final int typeId = 1;

  @override
  Contribution read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contribution(
      amount: fields[0] as double,
      date: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Contribution obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContributionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
