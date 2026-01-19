import 'dart:async';

import 'package:dartantic_ai/dartantic_ai.dart' hide ChatMessage;
import 'package:dartantic_ai/dartantic_ai.dart' as dai;

import 'package:multigateway/core/core.dart';

class ChatService {
  static Uri? _parseUri(String? value) {
    if (value == null || value.isEmpty) return null;
    return Uri.tryParse(value);
  }

  static Map<String, String>? _stringHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return null;
    return headers.map((key, value) => MapEntry(key, value.toString()));
  }

  static bool _shouldEnableThinking(
    ThinkingLevel level,
    ProviderType providerType, {
    required bool useResponsesApi,
  }) {
    if (level == ThinkingLevel.none) return false;
    switch (providerType) {
      case ProviderType.google:
      case ProviderType.anthropic:
        return true;
      case ProviderType.openai:
        return useResponsesApi;
      case ProviderType.ollama:
        return false;
    }
  }

  static Uri? _resolveBaseUrl({
    required LlmProviderInfo providerInfo,
    required bool useResponsesApi,
  }) {
    if (providerInfo.type == ProviderType.openai && useResponsesApi) {
      final base = providerInfo.baseUrl;
      if (base.isEmpty) return null;
      if (base.endsWith('/responses')) return _parseUri(base);
      final separator = base.endsWith('/') ? '' : '/';
      return _parseUri('$base${separator}responses');
    }

    return _parseUri(providerInfo.baseUrl);
  }

  static OpenAIChatOptions _buildOpenAIOptions(LlmChatConfig config) {
    return OpenAIChatOptions(topP: config.topP, maxTokens: config.maxTokens);
  }

  static OpenAIResponsesChatModelOptions _buildOpenAIResponsesOptions(
    LlmChatConfig config,
  ) {
    return OpenAIResponsesChatModelOptions(
      topP: config.topP,
      maxOutputTokens: config.maxTokens,
    );
  }

  static AnthropicChatOptions _buildAnthropicOptions(
    LlmChatConfig config, {
    required bool enableThinking,
  }) {
    return AnthropicChatOptions(
      temperature: config.temperature,
      topP: config.topP,
      topK: config.topK?.round(),
      maxTokens: config.maxTokens,
      thinkingBudgetTokens: enableThinking ? config.customThinkingTokens : null,
    );
  }

  static GoogleChatModelOptions _buildGoogleOptions(
    LlmChatConfig config, {
    required bool enableThinking,
  }) {
    return GoogleChatModelOptions(
      topP: config.topP,
      topK: config.topK?.round(),
      maxOutputTokens: config.maxTokens,
      thinkingBudgetTokens: enableThinking ? config.customThinkingTokens : null,
    );
  }

  static OllamaChatOptions _buildOllamaOptions(LlmChatConfig config) {
    return OllamaChatOptions(
      topP: config.topP,
      topK: config.topK?.round(),
      numPredict: config.maxTokens,
      numCtx: config.contextWindow,
    );
  }

  static McpClient? _buildDartanticMcpClient(McpInfo info) {
    switch (info.protocol) {
      case McpProtocol.stdio:
        // Stdio configuration is not available in the current model schema
        return null;
      case McpProtocol.streamableHttp:
      case McpProtocol.sse:
        if (info.url == null || info.url!.isEmpty) return null;
        final uri = Uri.tryParse(info.url!);
        if (uri == null) return null;
        return McpClient.remote(info.name, url: uri, headers: info.headers);
    }
  }

  static Future<List<dai.Tool>> _collectMcpTools(ChatProfile profile) async {
    if (profile.activeMcp.isEmpty) return const <dai.Tool>[];
    final mcpStorage = await McpInfoStorage.init();
    final tools = <dai.Tool>[];

    for (final active in profile.activeMcp) {
      final serverInfo = mcpStorage.getItem(active.id);
      if (serverInfo == null) continue;

      final client = _buildDartanticMcpClient(serverInfo);
      if (client == null) continue;

      try {
        final serverTools = await client.listTools();
        tools.addAll(
          serverTools.where(
            (t) =>
                active.activeToolNames.isEmpty ||
                active.activeToolNames.contains(t.name),
          ),
        );
      } catch (_) {
        // ignore failures to keep chat running
      } finally {
        client.dispose();
      }
    }

    return tools;
  }

  static List<dai.ChatMessage> _buildMessages({
    required String userText,
    required List<ChatMessage> history,
    required String systemPrompt,
  }) {
    final messages = <dai.ChatMessage>[];

    if (systemPrompt.isNotEmpty) {
      messages.add(dai.ChatMessage.system(systemPrompt));
    }

    for (final msg in history) {
      final content = msg.content ?? '';
      final role = _mapRole(msg.role);
      messages.add(dai.ChatMessage(role: role, parts: [dai.TextPart(content)]));
    }

    messages.add(
      dai.ChatMessage(
        role: dai.ChatMessageRole.user,
        parts: [dai.TextPart(userText)],
      ),
    );

    return messages;
  }

  static Stream<String> generateStream({
    required String userText,
    required List<ChatMessage> history,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    List<String>? allowedToolNames,
  }) async* {
    final providerRepo = await LlmProviderInfoStorage.init();

    final providers = providerRepo.getItems();
    if (providers.isEmpty) {
      throw Exception(
        'No provider configuration found. Please add a provider in Settings.',
      );
    }

    final providerInfo = providers.firstWhere(
      (p) => p.name == providerName,
      orElse: () => throw Exception('Provider "$providerName" not found.'),
    );

    var mcpTools = await _collectMcpTools(profile);
    if (allowedToolNames != null && allowedToolNames.isNotEmpty) {
      mcpTools = mcpTools
          .where((t) => allowedToolNames.contains(t.name))
          .toList();
    }
    final tools = mcpTools;

    final messages = _buildMessages(
      userText: userText,
      history: history,
      systemPrompt: profile.config.systemPrompt,
    );

    dai.ChatModel chatModel;
    final headers = _stringHeaders(providerInfo.config.headers) ?? const {};
    final useResponsesApi = providerInfo.config.responsesApi;
    final baseUrl = _resolveBaseUrl(
      providerInfo: providerInfo,
      useResponsesApi: useResponsesApi,
    );
    final config = profile.config;
    final enableThinking = _shouldEnableThinking(
      config.thinkingLevel,
      providerInfo.type,
      useResponsesApi: useResponsesApi,
    );

    switch (providerInfo.type) {
      case ProviderType.google:
        final provider = GoogleProvider(
          apiKey: providerInfo.auth.key,
          baseUrl: baseUrl,
          headers: headers,
        );
        chatModel = provider.createChatModel(
          name: modelName,
          tools: tools,
          temperature: config.temperature,
          enableThinking: enableThinking,
          options: _buildGoogleOptions(config, enableThinking: enableThinking),
        );
        break;
      case ProviderType.openai:
        if (useResponsesApi) {
          final provider = OpenAIResponsesProvider(
            apiKey: providerInfo.auth.key,
            baseUrl: baseUrl,
            headers: headers,
          );
          chatModel = provider.createChatModel(
            name: modelName,
            tools: tools,
            temperature: config.temperature,
            enableThinking: enableThinking,
            options: _buildOpenAIResponsesOptions(config),
          );
        } else {
          final provider = OpenAIProvider(
            apiKey: providerInfo.auth.key,
            baseUrl: baseUrl,
            headers: headers,
          );
          chatModel = provider.createChatModel(
            name: modelName,
            tools: tools,
            temperature: config.temperature,
            options: _buildOpenAIOptions(config),
          );
        }
        break;
      case ProviderType.anthropic:
        final provider = AnthropicProvider(
          apiKey: providerInfo.auth.key,
          headers: headers,
        );
        chatModel = provider.createChatModel(
          name: modelName,
          tools: tools,
          temperature: config.temperature,
          enableThinking: enableThinking,
          options: _buildAnthropicOptions(
            config,
            enableThinking: enableThinking,
          ),
        );
        break;
      case ProviderType.ollama:
        final provider = OllamaProvider(baseUrl: baseUrl, headers: headers);
        chatModel = provider.createChatModel(
          name: modelName,
          tools: tools,
          temperature: config.temperature,
          enableThinking: false,
          options: _buildOllamaOptions(config),
        );
        break;
    }

    try {
      await for (final resp in chatModel.sendStream(messages)) {
        final text = resp.output.parts
            .whereType<dai.TextPart>()
            .map((p) => p.text)
            .join();
        if (text.isNotEmpty) yield text;
      }
    } finally {
      chatModel.dispose();
    }
  }

  static Future<String> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    List<String>? allowedToolNames,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in generateStream(
      userText: userText,
      history: history,
      profile: profile,
      providerName: providerName,
      modelName: modelName,
      allowedToolNames: allowedToolNames,
    )) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  static dai.ChatMessageRole _mapRole(ChatRole role) {
    switch (role) {
      case ChatRole.user:
        return dai.ChatMessageRole.user;
      case ChatRole.model:
        return dai.ChatMessageRole.model;
      case ChatRole.system:
        return dai.ChatMessageRole.system;
      case ChatRole.tool:
      case ChatRole.developer:
        return dai.ChatMessageRole.user;
    }
  }
}
