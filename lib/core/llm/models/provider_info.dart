import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'provider_info.g.dart';

enum ProviderType {
  openai("OpenAI"),
  google('Google'),
  anthropic("Anthropic"),
  ollama("Ollama");

  final String name;

  const ProviderType(this.name);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ProviderInfo {
  final String name;
  final ProviderType type;
  final String? apiKey;
  final String? icon;
  final String baseUrl;

  ProviderInfo({
    required this.type,
    String? name,
    this.apiKey,
    this.icon,
    String? baseUrl,
  }) : name = name ?? _defaultName(type),
       baseUrl = baseUrl ?? _defaultBaseUrl(type);

  static String _defaultName(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'OpenAI';
      case ProviderType.anthropic:
        return 'Anthropic';
      case ProviderType.ollama:
        return 'Ollama';
      case ProviderType.google:
        return 'Google';
    }
  }

  static String _defaultBaseUrl(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'https://api.openai.com/v1';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com/v1';
      case ProviderType.ollama:
        return 'https://ollama.com';
      case ProviderType.google:
        return 'https://generativelanguage.googleapis.com/v1beta';
    }
  }

  // Helper method to get provider enum from string name
  static ProviderType? getTypeByName(String name) {
    try {
      return ProviderType.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => _$ProviderInfoToJson(this);

  factory ProviderInfo.fromJson(Map<String, dynamic> json) =>
      _$ProviderInfoFromJson(json);

  String toJsonString() => json.encode(toJson());

  factory ProviderInfo.fromJsonString(String jsonString) =>
      ProviderInfo.fromJson(json.decode(jsonString));
}

@JsonSerializable()
class OpenAIRoutes {
  final String chatCompletion;
  final String modelsRouteOrUrl;

  const OpenAIRoutes({
    this.chatCompletion = '/chat/completions',
    this.modelsRouteOrUrl = '/models',
  });

  Map<String, dynamic> toJson() => _$OpenAIRoutesToJson(this);

  factory OpenAIRoutes.fromJson(Map<String, dynamic> json) =>
      _$OpenAIRoutesFromJson(json);
}

@JsonSerializable()
class AnthropicRoutes {
  final String messages;
  final String models;
  final String anthropicVersion;

  const AnthropicRoutes({
    this.messages = '/messages',
    this.models = '/models',
    this.anthropicVersion = '2023-06-01',
  });

  Map<String, dynamic> toJson() => _$AnthropicRoutesToJson(this);

  factory AnthropicRoutes.fromJson(Map<String, dynamic> json) =>
      _$AnthropicRoutesFromJson(json);
}

@JsonSerializable()
class OllamaRoutes {
  final String chat;
  final String tags;
  final String embeddings;

  const OllamaRoutes({
    this.chat = '/api/chat',
    this.tags = '/api/tags',
    this.embeddings = '/api/embeddings',
  });

  Map<String, dynamic> toJson() => _$OllamaRoutesToJson(this);

  factory OllamaRoutes.fromJson(Map<String, dynamic> json) =>
      _$OllamaRoutesFromJson(json);
}

@JsonSerializable()
class GoogleRoutes {
  final String generateContent;
  final String streamGenerateContent;
  final String models;

  const GoogleRoutes({
    this.generateContent = '/v1beta/models/{model}:generateContent',
    this.streamGenerateContent = '/v1beta/models/{model}:streamGenerateContent',
    this.models = '/v1beta/models',
  });

  Map<String, dynamic> toJson() => _$GoogleRoutesToJson(this);

  factory GoogleRoutes.fromJson(Map<String, dynamic> json) =>
      _$GoogleRoutesFromJson(json);
}

@JsonSerializable()
class VertexAIConfig {
  final String projectId;
  final String location;

  const VertexAIConfig({this.projectId = '', this.location = 'us-central1'});

  Map<String, dynamic> toJson() => _$VertexAIConfigToJson(this);

  factory VertexAIConfig.fromJson(Map<String, dynamic> json) =>
      _$VertexAIConfigFromJson(json);
}

@JsonSerializable()
class AzureConfig {
  final String deploymentId;
  final String apiVersion;

  const AzureConfig({
    this.deploymentId = '',
    this.apiVersion = '2024-02-15-preview',
  });

  Map<String, dynamic> toJson() => _$AzureConfigToJson(this);

  factory AzureConfig.fromJson(Map<String, dynamic> json) =>
      _$AzureConfigFromJson(json);
}
