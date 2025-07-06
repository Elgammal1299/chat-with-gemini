// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageHiveModelAdapter extends TypeAdapter<MessageHiveModel> {
  @override
  final int typeId = 1;

  @override
  MessageHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageHiveModel(
      id: fields[0] as String,
      content: fields[1] as String,
      timestamp: fields[2] as DateTime,
      isUser: fields[3] as bool,
      conversationId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.isUser)
      ..writeByte(4)
      ..write(obj.conversationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
