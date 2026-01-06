// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageContent _$MessageContentFromJson(Map<String, dynamic> json) =>
    MessageContent(
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reasoningContent: json['reasoning_content'] as String?,
      aiMedia: (json['ai_media'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MessageContentToJson(MessageContent instance) =>
    <String, dynamic>{
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'attachments': instance.attachments,
      'reasoning_content': instance.reasoningContent,
      'ai_media': instance.aiMedia,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as String,
      role: $enumDecode(_$ChatRoleEnumMap, json['role']),
      versions: (json['versions'] as List<dynamic>?)
          ?.map((e) => MessageContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentVersionIndex:
          (json['current_version_index'] as num?)?.toInt() ?? 0,
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reasoningContent: json['reasoning_content'] as String?,
      aiMedia: (json['ai_media'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$ChatRoleEnumMap[instance.role]!,
      'versions': instance.versions.map((e) => e.toJson()).toList(),
      'current_version_index': instance.currentVersionIndex,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'attachments': instance.attachments,
      'reasoning_content': instance.reasoningContent,
      'ai_media': instance.aiMedia,
    };

const _$ChatRoleEnumMap = {
  ChatRole.user: 'user',
  ChatRole.model: 'model',
  ChatRole.system: 'system',
  ChatRole.tool: 'tool',
  ChatRole.developer: 'developer',
};
