import '../storage/provider_repository.dart';
import '../models/ai_agent.dart';
import '../models/chat/message.dart';
import '../models/provider.dart';
import 'ai/google/genai.dart';
import 'ai/openai/openai.dart';
import 'ai/anthropic/anthropic.dart';
import 'ai/ollama/ollama.dart';

class ChatService {
  static Future<String> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required AIAgent agent,
    required String providerName,
    required String modelName,
  }) async {
    final providerRepo = await ProviderRepository.init();
    final providers = providerRepo.getProviders();
    if (providers.isEmpty) {
      throw Exception(
        'No provider configuration found. Please add a provider in Settings.',
      );
    }

    final provider = providers.firstWhere(
      (p) => p.name == providerName,
      orElse: () => throw Exception('Provider "$providerName" not found.'),
    );

    // Ensure model exists in provider (optional validation)
    // final model = provider.models.firstWhere(
    //   (m) => m.name == modelName,
    //   orElse: () => throw Exception('Model "$modelName" not found for provider.'),
    // );

    final messagesWithCurrent = [
      ...history,
      ChatMessage(
        id: 'temp-user',
        role: ChatRole.user,
        content: userText,
        timestamp: DateTime.now(),
      ),
    ];

    // Optional: MCP integration logic (placeholder)
    // try {
    //   final mcpRepository = await MCPRepository.init();
    //   final mcpServers = agent.activeMCPServerIds
    //       .map((id) => mcpRepository.getItem(id))
    //       .whereType<MCPServer>()
    //       .toList();
    //   // TODO: attach tools from mcpServers
    // } catch (_) {}

    final systemInstruction = agent.systemPrompt;

    switch (provider.type) {
      case ProviderType.googleGenAI:
        final service = GoogleGenAIService(
          baseUrl:
              provider.baseUrl ??
              'https://generativelanguage.googleapis.com/v1beta',
          apiKey: provider.apiKey,
        );
        final response = await service.generateContent(
          model: modelName,
          contents: GoogleGenAIService.toGeminiContents(messagesWithCurrent),
          systemInstruction: systemInstruction,
        );
        return response.outputText;

      case ProviderType.openAI:
        final service = OpenAIService(
          baseUrl: provider.baseUrl ?? 'https://api.openai.com/v1',
          apiKey: provider.apiKey,
        );
        // OpenAI handles system instructions as a message
        var messages = OpenAIService.toOpenAIMessages(messagesWithCurrent);
        if (systemInstruction.isNotEmpty) {
          messages.insert(0, {'role': 'system', 'content': systemInstruction});
        }
        final response = await service.chatCompletions(
          model: modelName,
          messages: messages,
        );
        return response.choices.firstOrNull?.message.content ?? '';

      case ProviderType.anthropic:
        final service = AnthropicService(
          baseUrl: provider.baseUrl ?? 'https://api.anthropic.com/v1',
          apiKey: provider.apiKey,
        );
        // Anthropic passes system instruction separately
        final response = await service.messagesCreate(
          model: modelName,
          messages: AnthropicService.toAnthropicMessages(messagesWithCurrent),
          system: systemInstruction.isNotEmpty ? systemInstruction : null,
          maxTokens: 1024, // Default max tokens
        );
        return response.content.firstOrNull?.text ?? '';

      case ProviderType.ollama:
        final service = OllamaService(
          baseUrl: provider.baseUrl ?? 'http://localhost:11434',
          apiKey: provider.apiKey,
        );
        var messages = OllamaService.toOllamaMessages(messagesWithCurrent);
        if (systemInstruction.isNotEmpty) {
          // Ollama typically follows OpenAI style for system naming in chat
          messages.insert(0, {'role': 'system', 'content': systemInstruction});
        }
        final response = await service.chat(
          model: modelName,
          messages: messages,
          // create options/params if needed
        );
        return response.outputText;
    }
  }
}
