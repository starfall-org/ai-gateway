
import '../models/mcp/mcp.dart';
import '../storage/mcp_repository.dart';
import '../storage/provider_repository.dart';
import '../models/ai_agent.dart';
import '../models/chat/message.dart';
import '../models/provider.dart';

class ChatService {
  static Future<String> generateReply({
    required String userText,
    required List<Message> history,
    required AIAgent agent,
    required String providerName,
    required String modelName,
  }) async {
    final providerRepo = await ProviderRepository.init();
    final providers = providerRepo.getProviders();
    if (providers.isEmpty) {
      return 'No provider configured. Please add a provider in Settings > Providers.';
    }

    Provider provider = providers.where((p) => p.name == providerName).first;
    final model = provider.models.where((m) => m.name == modelName).first;

    try {
      final messagesWithCurrent = [
        ...history,
        Message(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          role: ChatRole.user,
          content: userText,
          timestamp: DateTime.now(),
        ),
      ];

      final mcpServers = agent.activeMCPServerIds
          .map((id) => MCPRepository().getItem(id))
          .whereType<MCPServer>() // Filter out nulls
          .toList();

      final chat = ChatOpenAI(
        apiKey: provider.apiKey,
        baseUrl: provider.baseUrl!,
        defaultOptions: ChatOpenAIOptions(
          model: model.name,
          temperature: agent.temperature,
          maxTokens: agent.maxTokens,
          tools: agent.tools,
        ),
      );
      final messages = messagesWithCurrent.map((m) => {
        switch (m.role) {
          case ChatRole.user:
            return UserMessage(content: m.content);
          case ChatRole.model:
            return AIMessage(content: m.content);
          case ChatRole.system:
            return SystemMessage(content: m.content);
          case ChatRole.tool:
            return ToolMessage(content: m.content);
        }
      }).toList();

      final response = await chat.invoke(messages);
      return response.content;
    } catch (e) {
      return 'Failed to generate response: $e';
    }
  }
}
