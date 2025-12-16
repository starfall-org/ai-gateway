import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/chat/message.dart' show ChatMessage, ChatRole;
import '../../../models/ai_model.dart';
import '../base.dart';
import 'models.dart';

/// Ollama service (local or remote) with API-compatible helpers.
///
/// Default endpoints (assuming baseUrl like http://localhost:11434):
/// - GET    /api/tags                 (list models)
/// - POST   /api/chat                 (chat)
/// - POST   /api/generate             (prompt completion)
/// - POST   /api/embeddings           (embeddings)
///
/// Notes:
/// - Auth: Hosted/remote Ollama endpoints often require `Authorization: Bearer <key>`.
///   This service will set the header if `apiKey` is provided, unless an `Authorization`
///   header already exists in custom headers. Local deployments may not require auth.
/// - Streaming: Ollama streams NDJSON (each line is a JSON object) and ends with {"done": true}.
class OllamaService extends AIServiceBase {
  OllamaService({
    required super.baseUrl,
    super.apiKey,
    super.headers,
  });

  /// Authorization handling for Ollama:
  /// - If `apiKey` is provided and no `Authorization` header exists, set `Bearer {apiKey}`.
  /// - If `Authorization` is already present in custom headers, it is respected as-is.
  @override
  void applyAuthHeaders(Map<String, String> headers) {
    if (apiKey != null &&
        apiKey!.isNotEmpty &&
        !headers.keys.any((k) => k.toLowerCase() == 'authorization')) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
  }

  String _join(String base, String path) => joinUrl(base, path);

  /// GET /api/tags
  /// Returns the list of available models (normalized to AIModel).
  Future<List<AIModel>> models({
    Map<String, String>? extraHeaders,
    String? customUrl,
  }) async {
    final url = _join(customUrl ?? baseUrl, '/api/tags');
    final res = await http.get(Uri.parse(url), headers: buildHeaders(extraHeaders));
    if (res.statusCode != 200) {
      throw Exception('Ollama /api/tags failed (${res.statusCode}): ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    final List list;
    if (decoded is Map && decoded['models'] is List) {
      list = decoded['models'] as List;
    } else if (decoded is List) {
      list = decoded;
    } else {
      list = const [];
    }

    return list.whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      // Normalize to AIModel.fromJson schema:
      // - Ollama usually returns 'model': 'llama3:latest' -> use as 'name'
      final name = (m['model'] ?? m['name'] ?? 'unknown').toString();
      final norm = <String, dynamic>{
        'name': name,
        // Hint context length if available (optional)
        if (m['details'] is Map && (m['details'] as Map)['context_length'] != null)
          'context_window': (m['details'] as Map)['context_length'],
      };
      return AIModel.fromJson(norm);
    }).toList();
  }

  /// POST /api/chat
  /// Chat using messages (user/assistant/system). Non-streaming.
  Future<OllamaChatResponse> chat({
    required String model,
    required List<Map<String, dynamic>> messages,
    Map<String, dynamic>? options,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
    bool? keepAlive,
  }) async {
    final url = _join(baseUrl, '/api/chat');
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (options != null) 'options': options,
      if (keepAlive != null) 'keep_alive': keepAlive,
      'stream': false,
      ...?extraBody,
    };
    final res = await http.post(
      Uri.parse(url),
      headers: buildHeaders(extraHeaders),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('Ollama /api/chat failed (${res.statusCode}): ${res.body}');
    }
    return OllamaChatResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  /// Streaming chat: emit delta text as soon as it arrives.
  Stream<String> chatStream({
    required String model,
    required List<Map<String, dynamic>> messages,
    Map<String, dynamic>? options,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
    bool? keepAlive,
  }) {
    final url = _join(baseUrl, '/api/chat');
    final headers = buildHeaders({
      ...?extraHeaders,
      // Ollama streams NDJSON
      'Accept': 'application/x-ndjson, application/json',
    });

    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (options != null) 'options': options,
      if (keepAlive != null) 'keep_alive': keepAlive,
      'stream': true,
      ...?extraBody,
    };

    final req = http.Request('POST', Uri.parse(url));
    req.headers.addAll(headers);
    req.body = jsonEncode(body);
    final client = http.Client();

    late StreamSubscription<String> sub;
    final controller = StreamController<String>(
      onCancel: () async {
        try {
          await sub.cancel();
        } catch (_) {}
        client.close();
      },
    );

    client.send(req).then((streamed) async {
      if (streamed.statusCode != 200) {
        final err = await http.Response.fromStream(streamed);
        controller.addError(Exception(
          'Ollama /api/chat failed (${err.statusCode}): ${err.body}',
        ));
        await controller.close();
        client.close();
        return;
      }

      sub = streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          final dataLine = line.trim();
          if (dataLine.isEmpty) return;

          try {
            final obj = jsonDecode(dataLine);
            if (obj is Map) {
              // Variants:
              // 1) {"message":{"role":"assistant","content":"..."},"done":false}
              final msg = obj['message'];
              if (msg is Map) {
                final c = msg['content'];
                if (c is String && c.isNotEmpty) {
                  controller.add(c);
                }
              }

              // 2) Generate-like: {"response":"...","done":false}
              final resp = obj['response'];
              if (resp is String && resp.isNotEmpty) {
                controller.add(resp);
              }

              // End of stream
              final done = obj['done'] == true;
              if (done) {
                controller.close();
                client.close();
              }
            }
          } catch (_) {
            // Ignore malformed chunk
          }
        },
        onError: (e, st) async {
          controller.addError(e, st);
          await controller.close();
          client.close();
        },
        onDone: () async {
          await controller.close();
          client.close();
        },
        cancelOnError: false,
      );
    }).catchError((e, st) async {
      controller.addError(e, st);
      await controller.close();
      client.close();
    });

    return controller.stream;
  }

  /// POST /api/generate
  /// Prompt completion without chat history. Non-streaming.
  Future<OllamaGenerateResponse> generate({
    required String model,
    required String prompt,
    Map<String, dynamic>? options,
    List<String>? imagesBase64, // for multimodal-capable models (if supported)
    bool? keepAlive,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _join(baseUrl, '/api/generate');
    final body = <String, dynamic>{
      'model': model,
      'prompt': prompt,
      if (options != null) 'options': options,
      if (imagesBase64 != null && imagesBase64.isNotEmpty) 'images': imagesBase64,
      if (keepAlive != null) 'keep_alive': keepAlive,
      'stream': false,
      ...?extraBody,
    };

    final res = await http.post(
      Uri.parse(url),
      headers: buildHeaders(extraHeaders),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('Ollama /api/generate failed (${res.statusCode}): ${res.body}');
    }
    return OllamaGenerateResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
    }

  /// Streaming generate.
  Stream<String> generateStream({
    required String model,
    required String prompt,
    Map<String, dynamic>? options,
    List<String>? imagesBase64,
    bool? keepAlive,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) {
    final url = _join(baseUrl, '/api/generate');
    final headers = buildHeaders({
      ...?extraHeaders,
      'Accept': 'application/x-ndjson, application/json',
    });

    final body = <String, dynamic>{
      'model': model,
      'prompt': prompt,
      if (options != null) 'options': options,
      if (imagesBase64 != null && imagesBase64.isNotEmpty) 'images': imagesBase64,
      if (keepAlive != null) 'keep_alive': keepAlive,
      'stream': true,
      ...?extraBody,
    };

    final req = http.Request('POST', Uri.parse(url));
    req.headers.addAll(headers);
    req.body = jsonEncode(body);
    final client = http.Client();

    late StreamSubscription<String> sub;
    final controller = StreamController<String>(
      onCancel: () async {
        try {
          await sub.cancel();
        } catch (_) {}
        client.close();
      },
    );

    client.send(req).then((streamed) async {
      if (streamed.statusCode != 200) {
        final err = await http.Response.fromStream(streamed);
        controller.addError(Exception(
          'Ollama /api/generate failed (${err.statusCode}): ${err.body}',
        ));
        await controller.close();
        client.close();
        return;
      }

      sub = streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          final dataLine = line.trim();
          if (dataLine.isEmpty) return;
          try {
            final obj = jsonDecode(dataLine);
            if (obj is Map) {
              final resp = obj['response'];
              if (resp is String && resp.isNotEmpty) {
                controller.add(resp);
              }
              final done = obj['done'] == true;
              if (done) {
                controller.close();
                client.close();
              }
            }
          } catch (_) {
            // ignore malformed chunk
          }
        },
        onError: (e, st) async {
          controller.addError(e, st);
          await controller.close();
          client.close();
        },
        onDone: () async {
          await controller.close();
          client.close();
        },
        cancelOnError: false,
      );
    }).catchError((e, st) async {
      controller.addError(e, st);
      await controller.close();
      client.close();
    });

    return controller.stream;
  }

  /// POST /api/embeddings
  Future<OllamaEmbeddingsResponse> embeddings({
    required String model,
    required String prompt,
    Map<String, dynamic>? options,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _join(baseUrl, '/api/embeddings');
    final body = <String, dynamic>{
      'model': model,
      'prompt': prompt,
      if (options != null) 'options': options,
      ...?extraBody,
    };
    final res = await http.post(
      Uri.parse(url),
      headers: buildHeaders(extraHeaders),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('Ollama /api/embeddings failed (${res.statusCode}): ${res.body}');
    }
    return OllamaEmbeddingsResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  /// Convert internal ChatMessage list to Ollama messages array.
  static List<Map<String, dynamic>> toOllamaMessages(List<ChatMessage> msgs) {
    final List<Map<String, dynamic>> out = [];
    for (final m in msgs) {
      final role = switch (m.role) {
        ChatRole.user => 'user',
        ChatRole.model => 'assistant',
        ChatRole.system => 'system',
        ChatRole.tool => 'tool',
      };
      out.add({'role': role, 'content': m.content});
    }
    return out;
  }
}

/* moved model classes to models.dart */