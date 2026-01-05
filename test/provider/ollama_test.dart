import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:llm/provider/ollama/ollama.dart';
import 'package:llm/models/api/ollama/chat.dart';
import 'package:llm/models/api/ollama/embed.dart';
import 'package:llm/models/api/ollama/tags.dart';

void main() {
  group('Ollama Provider Tests', () {
    test('chat - successful response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/api/chat'));
        expect(request.headers['Content-Type'], 'application/json');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'llama2');
        expect(body['messages'], isNotEmpty);

        return http.Response(
          jsonEncode({
            'model': 'llama2',
            'created_at': '2024-01-05T10:00:00Z',
            'message': {
              'role': 'assistant',
              'content': 'Hello! How can I help you today?',
            },
            'done': true,
            'total_duration': 1000000000,
            'load_duration': 100000000,
            'prompt_eval_count': 10,
            'prompt_eval_duration': 200000000,
            'eval_count': 20,
            'eval_duration': 700000000,
          }),
          200,
        );
      });

      final ollama = Ollama(
        baseUrl: 'http://localhost:11434',
      );

      final request = OllamaChatRequest(
        model: 'llama2',
        messages: [
          OllamaMessage(
            role: 'user',
            content: 'Hello',
          ),
        ],
      );

      expect(request.model, 'llama2');
      expect(request.messages.length, 1);
    });

    test('chat - with options', () {
      final request = OllamaChatRequest(
        model: 'llama2',
        messages: [
          OllamaMessage(
            role: 'user',
            content: 'Hello',
          ),
        ],
        options: OllamaOptions(
          temperature: 0.7,
          numPredict: 100,
          topK: 40,
          topP: 0.9,
        ),
      );

      final json = request.toJson();
      expect(json['options'], isNotNull);
      expect(json['options']['temperature'], 0.7);
      expect(json['options']['num_predict'], 100);
    });

    test('chat - with streaming', () {
      final request = OllamaChatRequest(
        model: 'llama2',
        messages: [
          OllamaMessage(
            role: 'user',
            content: 'Hello',
          ),
        ],
        stream: true,
      );

      final json = request.toJson();
      expect(json['stream'], true);
    });

    test('chat - with images', () {
      final request = OllamaChatRequest(
        model: 'llava',
        messages: [
          OllamaMessage(
            role: 'user',
            content: 'What is in this image?',
            images: [
              OllamaImage(data: 'base64encodedimage'),
            ],
          ),
        ],
      );

      final json = request.toJson();
      expect(json['messages'][0]['images'], hasLength(1));
    });

    test('chat - with tools', () {
      final request = OllamaChatRequest(
        model: 'llama2',
        messages: [
          OllamaMessage(
            role: 'user',
            content: 'What is the weather?',
          ),
        ],
        tools: [
          OllamaTool(
            function: OllamaFunction(
              name: 'get_weather',
              description: 'Get the current weather',
              parameters: {
                'type': 'object',
                'properties': {
                  'location': {
                    'type': 'string',
                    'description': 'The city name',
                  }
                },
                'required': ['location'],
              },
            ),
          ),
        ],
      );

      final json = request.toJson();
      expect(json['tools'], hasLength(1));
      expect(json['tools'][0]['function']['name'], 'get_weather');
    });

    test('chat response deserialization', () {
      final json = {
        'model': 'llama2',
        'created_at': '2024-01-05T10:00:00Z',
        'message': {
          'role': 'assistant',
          'content': 'Hello! How can I help you today?',
        },
        'done': true,
        'total_duration': 1000000000,
        'load_duration': 100000000,
        'prompt_eval_count': 10,
        'prompt_eval_duration': 200000000,
        'eval_count': 20,
        'eval_duration': 700000000,
      };

      final response = OllamaChatResponse.fromJson(json);
      expect(response.model, 'llama2');
      expect(response.done, true);
      expect(response.message.role, 'assistant');
      expect(response.message.content, contains('help'));
      expect(response.evalCount, 20);
    });

    test('chat stream response deserialization', () {
      final json = {
        'model': 'llama2',
        'created_at': '2024-01-05T10:00:00Z',
        'message': {
          'role': 'assistant',
          'content': 'Hello',
        },
        'done': false,
      };

      final response = OllamaChatStreamResponse.fromJson(json);
      expect(response.model, 'llama2');
      expect(response.done, false);
      expect(response.message?.content, 'Hello');
    });

    test('embeddings - request structure', () {
      final request = OllamaEmbedRequest(
        model: 'llama2',
        input: 'The quick brown fox jumps over the lazy dog',
      );

      final json = request.toJson();
      expect(json['model'], 'llama2');
      expect(json['input'], contains('fox'));
    });

    test('embeddings - with options', () {
      final request = OllamaEmbedRequest(
        model: 'llama2',
        input: 'Hello world',
        options: OllamaEmbedOptions(
          numCtx: 2048,
          numBatch: 512,
        ),
      );

      final json = request.toJson();
      expect(json['options'], isNotNull);
      expect(json['options']['num_ctx'], 2048);
    });

    test('embeddings response deserialization', () {
      final json = {
        'model': 'llama2',
        'embedding': [0.1, 0.2, 0.3, 0.4, 0.5],
      };

      final response = OllamaEmbedResponse.fromJson(json);
      expect(response.model, 'llama2');
      expect(response.embedding, hasLength(5));
      expect(response.embedding.first, 0.1);
    });

    test('tags response deserialization', () {
      final json = {
        'models': [
          {
            'name': 'llama2:latest',
            'modified_at': '2024-01-05T10:00:00Z',
            'size': 3825819519,
            'details': {
              'format': 'gguf',
              'family': 'llama',
              'families': ['llama'],
              'parameter_size': '7B',
              'quantization_level': 'Q4_0',
            },
          },
          {
            'name': 'mistral:latest',
            'modified_at': '2024-01-04T10:00:00Z',
            'size': 4109865159,
          },
        ],
      };

      final response = OllamaTagsResponse.fromJson(json);
      expect(response.models, hasLength(2));
      expect(response.models.first.name, 'llama2:latest');
      expect(response.models.first.details?.family, 'llama');
      expect(response.models.first.details?.parameterSize, '7B');
    });

    test('URI construction', () {
      final ollama = Ollama(
        baseUrl: 'http://localhost:11434',
      );

      final chatUri = ollama.uri('/api/chat');
      expect(chatUri.toString(), 'http://localhost:11434/api/chat');

      final tagsUri = ollama.uri('/api/tags');
      expect(tagsUri.toString(), 'http://localhost:11434/api/tags');
    });

    test('getHeaders - default headers', () {
      final ollama = Ollama(
        baseUrl: 'http://localhost:11434',
      );

      final headers = ollama.getHeaders();
      expect(headers['Content-Type'], 'application/json');
    });

    test('OllamaOptions - comprehensive', () {
      final options = OllamaOptions(
        temperature: 0.8,
        topK: 40,
        topP: 0.9,
        numPredict: 128,
        numCtx: 2048,
        repeatPenalty: 1.1,
        presencePenalty: 0.5,
        frequencyPenalty: 0.5,
        seed: 42,
      );

      final json = options.toJson();
      expect(json['temperature'], 0.8);
      expect(json['top_k'], 40);
      expect(json['top_p'], 0.9);
      expect(json['num_predict'], 128);
      expect(json['seed'], 42);
    });
  });
}
