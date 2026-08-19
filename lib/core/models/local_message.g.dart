// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_message.dart';

class LocalMessageAdapter extends TypeAdapter<LocalMessage> {
  @override
  final int typeId = 1;

  @override
  LocalMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalMessage(
      clientUuid: fields[0] as String,
      conversationId: fields[1] as int,
      body: fields[2] as String?,
      imagePaths: (fields[3] as List?)?.cast<String>(),
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocalMessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.clientUuid)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.imagePaths)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}