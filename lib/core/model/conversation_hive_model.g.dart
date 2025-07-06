// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationHiveModelAdapter extends TypeAdapter<ConversationHiveModel> {
  @override
  final int typeId = 0;

  @override
  ConversationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      lastMessagepreview: fields[2] as String,
      createdAt: fields[3] as DateTime,
      isUser: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.lastMessagepreview)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
