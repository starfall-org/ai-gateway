// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatProfile _$ChatProfileFromJson(Map<String, dynamic> json) => ChatProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      config: AiConfig.fromJson(json['config'] as Map<String, dynamic>),
      profileConversations: json['profile_conversations'] as bool? ?? false,
      conversationIds: (json['conversation_ids'] as List<dynamic>?)
              ?.map((e) => e as String?)
              .toList() ??
          const [],
      activeMcpServers: (json['active_m_c_p_servers'] as List<dynamic>?)
              ?.map((e) => ActiveMcpServer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activeBuiltInTools: (json['active_built_in_tools'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      persistChatSelection: json['persist_chat_selection'] as bool?,
    );

Map<String, dynamic> _$ChatProfileToJson(ChatProfile instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'config': instance.config.toJson(),
      'profile_conversations': instance.profileConversations,
      'conversation_ids': instance.conversationIds,
      'active_m_c_p_servers':
          instance.activeMcpServers.map((e) => e.toJson()).toList(),
      'active_built_in_tools': instance.activeBuiltInTools,
      'persist_chat_selection': instance.persistChatSelection,
    };

AiConfig _$AiConfigFromJson(Map<String, dynamic> json) => AiConfig(
      systemPrompt: json['system_prompt'] as String,
      enableStream: json['enable_stream'] as bool,
      topP: (json['top_p'] as num?)?.toDouble(),
      topK: (json['top_k'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      contextWindow: (json['context_window'] as num?)?.toInt() ?? 60000,
      conversationLength: (json['conversation_length'] as num?)?.toInt() ?? 10,
      maxTokens: (json['max_tokens'] as num?)?.toInt() ?? 4000,
      customThinkingTokens: (json['custom_thinking_tokens'] as num?)?.toInt(),
      thinkingLevel:
          $enumDecodeNullable(_$ThinkingLevelEnumMap, json['thinking_level']) ??
              ThinkingLevel.auto,
    );

Map<String, dynamic> _$AiConfigToJson(AiConfig instance) => <String, dynamic>{
      'system_prompt': instance.systemPrompt,
      'enable_stream': instance.enableStream,
      'top_p': instance.topP,
      'top_k': instance.topK,
      'temperature': instance.temperature,
      'context_window': instance.contextWindow,
      'conversation_length': instance.conversationLength,
      'max_tokens': instance.maxTokens,
      'custom_thinking_tokens': instance.customThinkingTokens,
      'thinking_level': _$ThinkingLevelEnumMap[instance.thinkingLevel]!,
    };

const _$ThinkingLevelEnumMap = {
  ThinkingLevel.none: 'none',
  ThinkingLevel.low: 'low',
  ThinkingLevel.medium: 'medium',
  ThinkingLevel.high: 'high',
  ThinkingLevel.auto: 'auto',
  ThinkingLevel.custom: 'custom',
};

ActiveMcpServer _$ActiveMcpServerFromJson(Map<String, dynamic> json) =>
    ActiveMcpServer(
      id: json['id'] as String,
      activeToolIds: (json['active_tool_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ActiveMcpServerToJson(ActiveMcpServer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active_tool_ids': instance.activeToolIds,
    };
