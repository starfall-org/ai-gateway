import 'package:hive/hive.dart';
import 'package:multigateway/core/profile/models/chat_profile.dart';

class ThinkingLevelAdapter extends TypeAdapter<ThinkingLevel> {
  @override
  final int typeId = 2;

  @override
  ThinkingLevel read(BinaryReader reader) {
    final index = reader.readByte();
    return ThinkingLevel.values[index];
  }

  @override
  void write(BinaryWriter writer, ThinkingLevel obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LlmChatConfigAdapter extends TypeAdapter<LlmChatConfig> {
  @override
  final int typeId = 3;

  @override
  LlmChatConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return LlmChatConfig(
      systemPrompt: fields[0] as String,
      enableStream: fields[1] as bool,
      topP: fields[2] as double?,
      topK: fields[3] as double?,
      temperature: fields[4] as double?,
      contextWindow: fields[5] as int? ?? 60000,
      conversationLength: fields[6] as int? ?? 10,
      maxTokens: fields[7] as int? ?? 4000,
      customThinkingTokens: fields[8] as int?,
      thinkingLevel: fields[9] as ThinkingLevel? ?? ThinkingLevel.auto,
    );
  }

  @override
  void write(BinaryWriter writer, LlmChatConfig obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.systemPrompt)
      ..writeByte(1)
      ..write(obj.enableStream)
      ..writeByte(2)
      ..write(obj.topP)
      ..writeByte(3)
      ..write(obj.topK)
      ..writeByte(4)
      ..write(obj.temperature)
      ..writeByte(5)
      ..write(obj.contextWindow)
      ..writeByte(6)
      ..write(obj.conversationLength)
      ..writeByte(7)
      ..write(obj.maxTokens)
      ..writeByte(8)
      ..write(obj.customThinkingTokens)
      ..writeByte(9)
      ..write(obj.thinkingLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlmChatConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActiveMcpAdapter extends TypeAdapter<ActiveMcp> {
  @override
  final int typeId = 4;

  @override
  ActiveMcp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return ActiveMcp(
      id: fields[0] as String,
      activeToolNames: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ActiveMcp obj) {
    writer
      ..writeByte(2) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.activeToolNames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveMcpAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModelToolAdapter extends TypeAdapter<ModelTool> {
  @override
  final int typeId = 5;

  @override
  ModelTool read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return ModelTool(
      modelId: fields[0] as String,
      providerId: fields[1] as String,
      toolName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ModelTool obj) {
    writer
      ..writeByte(3) // number of fields
      ..writeByte(0)
      ..write(obj.modelId)
      ..writeByte(1)
      ..write(obj.providerId)
      ..writeByte(2)
      ..write(obj.toolName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelToolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatProfileAdapter extends TypeAdapter<ChatProfile> {
  @override
  final int typeId = 6;

  @override
  ChatProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return ChatProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String?,
      config: fields[3] as LlmChatConfig,
      activeMcp: (fields[4] as List?)?.cast<ActiveMcp>() ?? const [],
      activeModelTools: (fields[5] as List?)?.cast<ModelTool>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, ChatProfile obj) {
    writer
      ..writeByte(6) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.config)
      ..writeByte(4)
      ..write(obj.activeMcp)
      ..writeByte(5)
      ..write(obj.activeModelTools);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}