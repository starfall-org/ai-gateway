import 'dart:convert';
import 'ai_model.dart';

enum ProviderType {
  googleGenAI('Google'),
  openAI("OpenAI"),
  anthropic("Anthropic"),
  ollama("Ollama");

  final String name;

  const ProviderType(this.name);
}

class CustomGoogleGenAIRoutes {
  final String generateContent;
  final String generateContentStream;
  final String models;

  CustomGoogleGenAIRoutes({
    this.generateContent = '/generateContent',
    this.generateContentStream = '/generateContentStream',
    this.models = '/models',
  });

  Map<String, String> toJson() {
    return {
      'generateContent': generateContent,
      'generateContentStream': generateContentStream,
      'models': models,
    };
  }

  static CustomGoogleGenAIRoutes fromJson(Map<String, String> json) {
    return CustomGoogleGenAIRoutes(
      generateContent: json['generateContent'] ?? '/generateContent',
      generateContentStream:
          json['generateContentStream'] ?? '/generateContentStream',
      models: json['models'] ?? '/models',
    );
  }
}

class CustomOpenAIRoutes {
  final String chatCompletion;
  final String responses;
  final String embeddings;
  final String models;

  CustomOpenAIRoutes({
    this.chatCompletion = '/chat/completions',
    this.responses = '/responses',
    this.embeddings = '/embeddings',
    this.models = '/models',
  });

  Map<String, String> toJson() {
    return {
      'chatCompletion': chatCompletion,
      'responses': responses,
      'embeddings': embeddings,
      'models': models,
    };
  }

  static CustomOpenAIRoutes fromJson(Map<String, String> json) {
    return CustomOpenAIRoutes(
      chatCompletion: json['chatCompletion'] ?? '/chat/completions',
      responses: json['responses'] ?? '/responses',
      embeddings: json['embeddings'] ?? '/embeddings',
      models: json['models'] ?? '/models',
    );
  }
}

class CustomAnthropicRoutes {
  final String messages;
  final String models;

  CustomAnthropicRoutes({this.messages = '/messages', this.models = '/models'});

  Map<String, String> toJson() {
    return {'messages': messages, 'models': models};
  }

  static CustomAnthropicRoutes fromJson(Map<String, String> json) {
    return CustomAnthropicRoutes(
      messages: json['messages'] ?? '/messages',
      models: json['models'] ?? '/models',
    );
  }
}

class CustomOllamaRoutes {
  final String chat;
  final String tags;

  CustomOllamaRoutes({this.chat = '/chat', this.tags = '/tags'});

  Map<String, String> toJson() {
    return {'chat': chat, 'tags': tags};
  }

  static CustomOllamaRoutes fromJson(Map<String, String> json) {
    return CustomOllamaRoutes(
      chat: json['chat'] ?? '/chat',
      tags: json['tags'] ?? '/tags',
    );
  }
}

class Provider {
  final String name;
  final ProviderType type;
  final String? apiKey;
  final String? logoUrl;
  final String? baseUrl;
  final CustomGoogleGenAIRoutes? customGoogleGenAIRoutes;
  final CustomOpenAIRoutes? customOpenAIRoutes;
  final CustomAnthropicRoutes? customAnthropicRoutes;
  final CustomOllamaRoutes? customOllamaRoutes;
  final Map<String, String> headers;
  final List<AIModel> models;

  Provider({
    required this.type,
    String? name,
    this.apiKey,
    this.logoUrl,
    String? baseUrl,
    this.customGoogleGenAIRoutes,
    this.customOpenAIRoutes,
    this.customAnthropicRoutes,
    this.customOllamaRoutes,
    this.headers = const {},
    this.models = const [],
  }) : baseUrl = baseUrl ?? _defaultBaseUrl(type),
       name = name ?? _defaultName(type);

  static String _defaultName(ProviderType type) {
    switch (type) {
      case ProviderType.openAI:
        return 'OpenAI';
      case ProviderType.anthropic:
        return 'Anthropic';
      case ProviderType.ollama:
        return 'Ollama';
      case ProviderType.googleGenAI:
        return 'Google Generative AI';
    }
  }

  static String? _defaultBaseUrl(ProviderType type) {
    switch (type) {
      case ProviderType.openAI:
        return 'https://api.openai.com/v1';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com/v1';
      case ProviderType.ollama:
        return 'https://ollama.com';
      case ProviderType.googleGenAI:
        return 'https://generativelanguage.googleapis.com/v1beta';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'logoUrl': logoUrl,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'headers': headers,
      'customGoogleGenAIRoutes': customGoogleGenAIRoutes?.toJson(),
      'customOpenAIRoutes': customOpenAIRoutes?.toJson(),
      'customAnthropicRoutes': customAnthropicRoutes?.toJson(),
      'customOllamaRoutes': customOllamaRoutes?.toJson(),
      'models': models.map((m) => m.toJson()).toList(),
    };
  }

  factory Provider.fromJson(Map<String, dynamic> json) {
    var modelsJson = json['models'];
    List<AIModel> parsedModels = [];

    if (modelsJson != null) {
      if (modelsJson is List &&
          modelsJson.isNotEmpty &&
          modelsJson.first is String) {
        parsedModels = modelsJson
            .map((e) => AIModel(name: e as String))
            .toList();
      } else {
        parsedModels = (modelsJson as List)
            .map((e) => AIModel.fromJson(e))
            .toList();
      }
    }

    return Provider(
      type: ProviderType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      apiKey: json['apiKey'] as String?,
      baseUrl: json['baseUrl'] as String?,
      customGoogleGenAIRoutes: json['customGoogleGenAIRoutes'] != null
          ? CustomGoogleGenAIRoutes.fromJson(json['customGoogleGenAIRoutes'])
          : null,
      customOpenAIRoutes: json['customOpenAIRoutes'] != null
          ? CustomOpenAIRoutes.fromJson(json['customOpenAIRoutes'])
          : null,
      customAnthropicRoutes: json['customAnthropicRoutes'] != null
          ? CustomAnthropicRoutes.fromJson(json['customAnthropicRoutes'])
          : null,
      customOllamaRoutes: json['customOllamaRoutes'] != null
          ? CustomOllamaRoutes.fromJson(json['customOllamaRoutes'])
          : null,
      headers: Map<String, String>.from(json['headers'] ?? {}),
      models: parsedModels,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Provider.fromJsonString(String jsonString) =>
      Provider.fromJson(json.decode(jsonString));
}
