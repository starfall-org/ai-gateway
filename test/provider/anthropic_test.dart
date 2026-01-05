import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:llm/provider/anthropic/anthropic.dart';
import 'package:llm/models/api/anthropic/messages.dart';

void main() {
  group('Anthropic Provider Tests', () {
    test('messages - successful response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/messages'));
        expect(request.headers['x-api-key'], 'test-api-key');
        expect(request.headers['anthropic-version'], '2023-06-01');
        expect(request.headers['Content-Type'], 'application/json');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'claude-3-opus-20240229');
        expect(body['messages'], isNotEmpty);

        return http.Response(
          jsonEncode({
            'id': 'msg_123',
            'type': 'message',
            'role': 'assistant',
            'content': [
              {
                'type': 'text',
                'text': 'Hello! How can I assist you today?',
              }
            ],
            'model': 'claude-3-opus-20240229',
            'stop_reason': 'end_turn',
            'stop_sequence': null,
            'usage': {
              'input_tokens': 10,
              'output_tokens': 20,
            },
          }),
          200,
        );
      });

      final anthropic = Anthropic(
        apiKey: 'test-api-key',
        baseUrl: 'https://api.anthropic.com/v1',
      );

      final request = AnthropicMessagesRequest(
        model: 'claude-3-opus-20240229',
        messages: [
          AnthropicMessage(
            role: 'user',
            content: 'Hello',
          ),
        ],
        maxTokens: 1024,
      );

      expect(request.model, 'claude-3-opus-20240229');
      expect(request.messages.length, 1);
      expect(request.maxTokens, 1024);
    });

    test('messages - with system prompt', () {
      final request = AnthropicMessagesRequest(
        model: 'claude-3-opus-20240229',
        messages: [
          AnthropicMessage(
            role: 'user',
            content: 'Hello',
          ),
        ],
        maxTokens: 1024,
        system: 'You are a helpful assistant.',
        temperature: 0.7,
      );

      final json = request.toJson();
      expect(json['system'], 'You are a helpful assistant.');
      expect(json['temperature'], 0.7);
      expect(json['max_tokens'], 1024);
    });

    test('messages - with tools', () {
      final request = AnthropicMessagesRequest(
        model: 'claude-3-opus-20240229',
        messages: [
          AnthropicMessage(
            role: 'user',
            content: 'What is the weather?',
          ),
        ],
        maxTokens: 1024,
        tools: [
          AnthropicTool(
            name: 'get_weather',
            description: 'Get the current weather',
            inputSchema: {
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
        ],
      );

      final json = request.toJson();
      expect(json['tools'], hasLength(1));
      expect(json['tools'][0]['name'], 'get_weather');
    });

    test('messages response deserialization', () {
      final json = {
        'id': 'msg_123',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {
            'type': 'text',
            'text': 'Hello! How can I assist you today?',
          }
        ],
        'model': 'claude-3-opus-20240229',
        'stop_reason': 'end_turn',
        'stop_sequence': null,
        'usage': {
          'input_tokens': 10,
          'output_tokens': 20,
        },
      };

      final response = AnthropicMessagesResponse.fromJson(json);
      expect(response.id, 'msg_123');
      expect(response.type, 'message');
      expect(response.role, 'assistant');
      expect(response.content, hasLength(1));
      expect(response.content.first.text, contains('assist'));
      expect(response.usage.inputTokens, 10);
      expect(response.usage.outputTokens, 20);
    });

    test('getHeaders - includes anthropic-version', () {
      final anthropic = Anthropic(
        apiKey: 'test-api-key',
        baseUrl: 'https://api.anthropic.com/v1',
        anthropicVersion: '2023-06-01',
      );

      final headers = anthropic.getHeaders();
      expect(headers['x-api-key'], 'test-api-key');
      expect(headers['anthropic-version'], '2023-06-01');
      expect(headers['Content-Type'], 'application/json');
    });

    test('getHeaders - custom anthropic version', () {
      final anthropic = Anthropic(
        apiKey: 'test-api-key',
        baseUrl: 'https://api.anthropic.com/v1',
        anthropicVersion: '2024-01-01',
      );

      final headers = anthropic.getHeaders();
      expect(headers['anthropic-version'], '2024-01-01');
    });

    test('URI construction', () {
      final anthropic = Anthropic(
        apiKey: 'test-api-key',
        baseUrl: 'https://api.anthropic.com/v1',
      );

      final uri = anthropic.uri('/messages');
      expect(uri.toString(), 'https://api.anthropic.com/v1/messages');
    });

    test('messages - with streaming flag', () {
      final request = AnthropicMessagesRequest(
        model: 'claude-3-opus-20240229',
        messages: [
          AnthropicMessage(
            role: 'user',
            content: 'Hello',
          ),
        ],
        maxTokens: 1024,
        stream: true,
      );

      final json = request.toJson();
      expect(json['stream'], true);
    });

    test('AnthropicContent - text type', () {
      final content = AnthropicContent(
        type: 'text',
        text: 'Hello world',
      );

      final json = content.toJson();
      expect(json['type'], 'text');
      expect(json['text'], 'Hello world');
    });

    test('AnthropicContent - image type', () {
      final content = AnthropicContent(
        type: 'image',
        source: 'base64',
        mediaType: 'image/jpeg',
        data: 'base64encodeddata',
      );

      final json = content.toJson();
      expect(json['type'], 'image');
      expect(json['media_type'], 'image/jpeg');
    });

    test('AnthropicUsage serialization', () {
      final usage = AnthropicUsage(
        inputTokens: 100,
        outputTokens: 200,
      );

      final json = usage.toJson();
      expect(json['input_tokens'], 100);
      expect(json['output_tokens'], 200);
    });
  });
}
