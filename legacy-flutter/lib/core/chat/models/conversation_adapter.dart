import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:multigateway/core/chat/models/conversation.dart';

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 1;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return Conversation(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      messages: _decodeMessages(fields[4] as String),
      tokenCount: fields[5] as int?,
      providerId: fields[6] as String,
      modelId: fields[7] as String,
      profileId: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(9) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.updatedAt.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(_encodeMessages(obj.messages))
      ..writeByte(5)
      ..write(obj.tokenCount)
      ..writeByte(6)
      ..write(obj.providerId)
      ..writeByte(7)
      ..write(obj.modelId)
      ..writeByte(8)
      ..write(obj.profileId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  /// Encode messages list to JSON string for storage
  String _encodeMessages(List<Map<String, dynamic>> messages) {
    try {
      return json.encode(messages);
    } catch (e) {
      return '[]'; // Fallback to empty array
    }
  }

  /// Decode JSON string back to messages list
  List<Map<String, dynamic>> _decodeMessages(String messagesJson) {
    try {
      final decoded = json.decode(messagesJson);
      if (decoded is List) {
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return []; // Fallback to empty array
    }
  }
}