// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderInfo _$ProviderInfoFromJson(Map<String, dynamic> json) => ProviderInfo(
      type: $enumDecode(_$ProviderTypeEnumMap, json['type']),
      name: json['name'] as String?,
      apiKey: json['apiKey'] as String?,
      icon: json['icon'] as String?,
      baseUrl: json['baseUrl'] as String?,
    );

Map<String, dynamic> _$ProviderInfoToJson(ProviderInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$ProviderTypeEnumMap[instance.type]!,
      'apiKey': instance.apiKey,
      'icon': instance.icon,
      'baseUrl': instance.baseUrl,
    };

const _$ProviderTypeEnumMap = {
  ProviderType.openai: 'openai',
  ProviderType.google: 'google',
  ProviderType.anthropic: 'anthropic',
  ProviderType.ollama: 'ollama',
};

OpenAIRoutes _$OpenAIRoutesFromJson(Map<String, dynamic> json) => OpenAIRoutes(
      chatCompletion: json['chatCompletion'] as String? ?? '/chat/completions',
      modelsRouteOrUrl: json['modelsRouteOrUrl'] as String? ?? '/models',
    );

Map<String, dynamic> _$OpenAIRoutesToJson(OpenAIRoutes instance) =>
    <String, dynamic>{
      'chatCompletion': instance.chatCompletion,
      'modelsRouteOrUrl': instance.modelsRouteOrUrl,
    };

AnthropicRoutes _$AnthropicRoutesFromJson(Map<String, dynamic> json) =>
    AnthropicRoutes(
      messages: json['messages'] as String? ?? '/messages',
      models: json['models'] as String? ?? '/models',
      anthropicVersion: json['anthropicVersion'] as String? ?? '2023-06-01',
    );

Map<String, dynamic> _$AnthropicRoutesToJson(AnthropicRoutes instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'models': instance.models,
      'anthropicVersion': instance.anthropicVersion,
    };

OllamaRoutes _$OllamaRoutesFromJson(Map<String, dynamic> json) => OllamaRoutes(
      chat: json['chat'] as String? ?? '/api/chat',
      tags: json['tags'] as String? ?? '/api/tags',
      embeddings: json['embeddings'] as String? ?? '/api/embeddings',
    );

Map<String, dynamic> _$OllamaRoutesToJson(OllamaRoutes instance) =>
    <String, dynamic>{
      'chat': instance.chat,
      'tags': instance.tags,
      'embeddings': instance.embeddings,
    };

GoogleRoutes _$GoogleRoutesFromJson(Map<String, dynamic> json) => GoogleRoutes(
      generateContent: json['generateContent'] as String? ??
          '/v1beta/models/{model}:generateContent',
      streamGenerateContent: json['streamGenerateContent'] as String? ??
          '/v1beta/models/{model}:streamGenerateContent',
      models: json['models'] as String? ?? '/v1beta/models',
    );

Map<String, dynamic> _$GoogleRoutesToJson(GoogleRoutes instance) =>
    <String, dynamic>{
      'generateContent': instance.generateContent,
      'streamGenerateContent': instance.streamGenerateContent,
      'models': instance.models,
    };

VertexAIConfig _$VertexAIConfigFromJson(Map<String, dynamic> json) =>
    VertexAIConfig(
      projectId: json['projectId'] as String? ?? '',
      location: json['location'] as String? ?? 'us-central1',
    );

Map<String, dynamic> _$VertexAIConfigToJson(VertexAIConfig instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'location': instance.location,
    };

AzureConfig _$AzureConfigFromJson(Map<String, dynamic> json) => AzureConfig(
      deploymentId: json['deploymentId'] as String? ?? '',
      apiVersion: json['apiVersion'] as String? ?? '2024-02-15-preview',
    );

Map<String, dynamic> _$AzureConfigToJson(AzureConfig instance) =>
    <String, dynamic>{
      'deploymentId': instance.deploymentId,
      'apiVersion': instance.apiVersion,
    };
