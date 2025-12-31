library provider;

import '../models/api/api.dart';
import '../models/llm_provider/provider_info.dart';
import 'anthropic/anthropic.dart';
import 'googleai/aistudio.dart';
import 'googleai/vertexai.dart';
import 'ollama/ollama.dart';
import 'openai/azure.dart';
import 'openai/openai.dart';

export '../models/api/api.dart';
export 'anthropic/anthropic.dart';
export 'googleai/aistudio.dart';
export 'googleai/vertexai.dart';
export 'ollama/ollama.dart';
export 'openai/azure.dart';
export 'openai/openai.dart';

/// A factory class for creating LLM providers based on provider configuration
class ProviderFactory {
  /// Creates an LLM provider instance based on the provider configuration
  static AIBaseApi createProvider(Provider providerConfig) {
    switch (providerConfig.type) {
      case ProviderType.openai:
        if (providerConfig.azureAI) {
          return AzureOpenAI(
            apiKey: providerConfig.apiKey ?? '',
            baseUrl: providerConfig.baseUrl,
            deployment: providerConfig.azureConfig?.deploymentId ?? '',
            apiVersion: providerConfig.azureConfig?.apiVersion ?? '2024-02-15-preview',
            headers: providerConfig.headers,
          );
        }
        return OpenAI(
          apiKey: providerConfig.apiKey ?? '',
          baseUrl: providerConfig.baseUrl,
          headers: providerConfig.headers,
        );
      
      case ProviderType.anthropic:
        return Anthropic(
          apiKey: providerConfig.apiKey ?? '',
          baseUrl: providerConfig.baseUrl,
          headers: providerConfig.headers,
        );
      
      case ProviderType.google:
        if (providerConfig.vertexAI) {
          return VertexAI(
            apiKey: providerConfig.apiKey ?? '',
            baseUrl: providerConfig.baseUrl,
            projectId: providerConfig.vertexAIConfig?.projectId ?? '',
            location: providerConfig.vertexAIConfig?.location ?? 'us-central1',
            headers: providerConfig.headers,
          );
        }
        return AIStudio(
          apiKey: providerConfig.apiKey ?? '',
          baseUrl: providerConfig.baseUrl,
          headers: providerConfig.headers,
        );
      
      case ProviderType.ollama:
        return Ollama(
          baseUrl: providerConfig.baseUrl,
          headers: providerConfig.headers,
        );
      
      default:
        throw UnsupportedError('Unsupported provider type: ${providerConfig.type}');
    }
  }

  /// Generates a response using the specified provider configuration
  static Future<AIResponse> generate(
    Provider providerConfig,
    AIRequest request,
  ) async {
    final provider = createProvider(providerConfig);
    return await provider.generate(request);
  }

  /// Generates a streaming response using the specified provider configuration
  static Stream<AIResponse> generateStream(
    Provider providerConfig,
    AIRequest request,
  ) {
    final provider = createProvider(providerConfig);
    return provider.generateStream(request) ?? Stream.empty();
  }

  /// Lists available models for the specified provider
  static Future<List<AIModel>> listModels(Provider providerConfig) async {
    final provider = createProvider(providerConfig);
    return await provider.listModels();
  }

  /// Generates embeddings using the specified provider
  static Future<dynamic> embed(
    Provider providerConfig, {
    required String model,
    required dynamic input,
    Map<String, dynamic> options = const {},
  }) async {
    final provider = createProvider(providerConfig);
    return await provider.embed(model: model, input: input, options: options);
  }
}

/// Extension methods for the Provider class to directly use API methods
extension ProviderApiExtension on Provider {
  /// Generates a response using this provider configuration
  Future<AIResponse> generate(AIRequest request) async {
    return await ProviderFactory.generate(this, request);
  }

  /// Generates a streaming response using this provider configuration
  Stream<AIResponse> generateStream(AIRequest request) {
    return ProviderFactory.generateStream(this, request);
  }

  /// Lists available models for this provider
  Future<List<AIModel>> listModels() async {
    return await ProviderFactory.listModels(this);
  }

  /// Generates embeddings using this provider
  Future<dynamic> embed({
    required String model,
    required dynamic input,
    Map<String, dynamic> options = const {},
  }) async {
    return await ProviderFactory.embed(
      this,
      model: model,
      input: input,
      options: options,
    );
  }
}
