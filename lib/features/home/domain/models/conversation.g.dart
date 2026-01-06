// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tokenCount: (json['token_count'] as num?)?.toInt(),
      isAgentConversation: json['is_agent_conversation'] as bool? ?? false,
      providerName: json['provider_name'] as String?,
      modelName: json['model_name'] as String?,
      enabledToolNames: (json['enabled_tool_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'token_count': instance.tokenCount,
      'is_agent_conversation': instance.isAgentConversation,
      'provider_name': instance.providerName,
      'model_name': instance.modelName,
      'enabled_tool_names': instance.enabledToolNames,
    };
