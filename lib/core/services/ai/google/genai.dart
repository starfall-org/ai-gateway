import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/chat/message.dart' show ChatMessage, ChatRole;
import '../../../models/ai_model.dart';
import '../base.dart';
import 'models.dart';

/// Google Generative AI (Gemini) service implementing common API-compatible methods.
/// - Base URL (default): https://generativelanguage.googleapis.com/v1beta
/// - Auth: uses 'x-goog-api-key' header (NOT Bearer Authorization)
///
/// Endpoints used:
/// - GET    /models
/// - POST   /models/{model}:generateContent
/// - POST   /models/{model}:streamGenerateContent (streaming)
/// - POST   /models/{model}:embedContent (embeddings)
class GoogleGenAIService extends AIServiceBase {
  GoogleGenAIService({
    required super.baseUrl,
    super.apiKey,
    super.headers,
  });

  /// Override to use 'x-goog-api-key' instead of 'Authorization: Bearer ...'
  @override
  void applyAuthHeaders(Map<String, String> headers) {
    // Ensure content-type is json (AIServiceBase already sets this by default)
    // Replace default Authorization with x-goog-api-key for Google
    if (headers.containsKey('Authorization')) {
      headers.remove('Authorization');
    }
    if (apiKey != null &&
        apiKey!.isNotEmpty &&
        !headers.keys.any((k) => k.toLowerCase() == 'x-goog-api-key')) {
      headers['x-goog-api-key'] = apiKey!;
    }
  }

  String _join(String base, String path) => joinUrl(base, path);

  String _modelPath(String model) {
    // Accept both "models/gemini-1.5-flash" and "gemini-1.5-flash"
    if (model.startsWith('models/')) return model;
    return 'models/$model';
  }

  /// Optionally append ?key= if header is not present (defensive for some proxies).
  String _appendKeyIfMissing(String url, Map<String, String> headers) {
    final hasHeaderKey =
        headers.keys.any((k) => k.toLowerCase() == 'x-goog-api-key');
    if (hasHeaderKey || apiKey == null || apiKey!.isEmpty) return url;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}key=${Uri.encodeQueryComponent(apiKey!)}';
  }

  /// GET /models
  /// Returns list of AIModel (normalized from Google response).
  Future<List<AIModel>> models({
    Map<String, String>? extraHeaders,
    String? customModelsUrl,
  }) async {
    var url = _join(customModelsUrl ?? baseUrl, '/models');
    final headers = buildHeaders(extraHeaders);
    url = _appendKeyIfMissing(url, headers);

    final res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode != 200) {
      throw Exception('GoogleGenAI /models failed (${res.statusCode}): ${res.body}');
    }
    final decoded = jsonDecode(res.body);

    List list;
    if (decoded is Map && decoded['models'] is List) {
      list = decoded['models'] as List;
    } else if (decoded is Map && decoded['data'] is List) {
      list = decoded['data'] as List;
    } else if (decoded is List) {
      list = decoded;
    } else {
      list = const [];
    }

    return list.whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      // Normalize fields for AIModel.fromJson
      // Google returns e.g. { name: 'models/gemini-1.5-flash', inputTokenLimit: 1048576, ... }
      // Already compatible with AIModel.fromJson:
      // - name
      // - inputTokenLimit
      return AIModel.fromJson(m);
    }).toList();
  }

  /// POST /models/{model}:generateContent
  /// Minimal text generation. Returns parsed response wrapper.
  Future<GoogleGenerateContentResponse> generateContent({
    required String model,
    required List<Map<String, dynamic>> contents,
    String? systemInstruction,
    Map<String, dynamic>? generationConfig,
    List<Map<String, dynamic>>? safetySettings,
    List<Map<String, dynamic>>? tools,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final modelPath = _modelPath(model);
    var url = _join(baseUrl, '/$modelPath:generateContent');
    final headers = buildHeaders(extraHeaders);
    url = _appendKeyIfMissing(url, headers);

    final body = <String, dynamic>{
      'contents': contents,
      if (systemInstruction != null && systemInstruction.isNotEmpty)
        'system_instruction': {
          'parts': [
            {'text': systemInstruction}
          ]
        },
      if (generationConfig != null) 'generationConfig': generationConfig,
      if (safetySettings != null) 'safetySettings': safetySettings,
      if (tools != null) 'tools': tools,
      ...?extraBody,
    };

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'GoogleGenAI :generateContent failed (${res.statusCode}): ${res.body}',
      );
    }
    return GoogleGenerateContentResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  /// Streaming variant using POST /models/{model}:streamGenerateContent
  /// Emits delta text as soon as chunks arrive. Attempts to parse both SSE-style
  /// ("data: {...}") and plain JSON lines.
  Stream<String> generateContentStream({
    required String model,
    required List<Map<String, dynamic>> contents,
    String? systemInstruction,
    Map<String, dynamic>? generationConfig,
    List<Map<String, dynamic>>? safetySettings,
    List<Map<String, dynamic>>? tools,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) {
    final modelPath = _modelPath(model);
    var url = _join(baseUrl, '/$modelPath:streamGenerateContent');
    final headers = buildHeaders({
      ...?extraHeaders,
      // Google streaming often works with application/json; accept SSE too for proxies.
      'Accept': 'text/event-stream, application/json',
    });
    url = _appendKeyIfMissing(url, headers);

    final body = <String, dynamic>{
      'contents': contents,
      if (systemInstruction != null && systemInstruction.isNotEmpty)
        'system_instruction': {
          'parts': [
            {'text': systemInstruction}
          ]
        },
      if (generationConfig != null) 'generationConfig': generationConfig,
      if (safetySettings != null) 'safetySettings': safetySettings,
      if (tools != null) 'tools': tools,
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
          'GoogleGenAI :streamGenerateContent failed (${err.statusCode}): ${err.body}',
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
          final dataLine = line.startsWith('data: ')
              ? line.substring(6).trim()
              : line.trim();

          if (dataLine.isEmpty) return;
          if (dataLine == '[DONE]') {
            controller.close();
            client.close();
            return;
          }

          try {
            final obj = jsonDecode(dataLine);
            final text = _extractTextFromGenerateContentChunk(obj);
            if (text != null && text.isNotEmpty) {
              controller.add(text);
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

  /// POST /models/{model}:embedContent
  /// Returns embedding vector (if supported by the model).
  Future<GoogleEmbedContentResponse> embedContent({
    required String model,
    required String input,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final modelPath = _modelPath(model);
    var url = _join(baseUrl, '/$modelPath:embedContent');
    final headers = buildHeaders(extraHeaders);
    url = _appendKeyIfMissing(url, headers);

    final body = <String, dynamic>{
      'content': {
        'parts': [
          {'text': input}
        ]
      },
      ...?extraBody,
    };

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'GoogleGenAI :embedContent failed (${res.statusCode}): ${res.body}',
      );
    }
    return GoogleEmbedContentResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  /// Convert internal chat messages to Gemini "contents" format.
  /// - ChatRole.user  -> role: 'user'
  /// - ChatRole.model -> role: 'model'
  /// - ChatRole.system/tool are omitted here; system can be passed via `systemInstruction`.
  static List<Map<String, dynamic>> toGeminiContents(List<ChatMessage> msgs) {
    final List<Map<String, dynamic>> out = [];
    for (final m in msgs) {
      switch (m.role) {
        case ChatRole.user:
          out.add({
            'role': 'user',
            'contents': null, // tolerate alternative shapes
            'parts': [
              {'text': m.content}
            ],
          }..remove('contents'));
          break;
        case ChatRole.model:
          out.add({
            'role': 'model',
            'parts': [
              {'text': m.content}
            ],
          });
          break;
        case ChatRole.system:
        case ChatRole.tool:
          // skip; handled elsewhere or unsupported by default mapping
          break;
      }
    }
    return out;
  }

  /// Concatenate system messages into one system instruction string.
  static String? extractSystemInstruction(List<ChatMessage> msgs) {
    final buf = StringBuffer();
    for (final m in msgs) {
      if (m.role == ChatRole.system && m.content.isNotEmpty) {
        if (buf.isNotEmpty) buf.write('\n\n');
        buf.write(m.content);
      }
    }
    return buf.isEmpty ? null : buf.toString();
  }

  // Helpers

  /// Try to extract plain text from a generateContent (or streamed) response chunk.
  /// Supports both full responses and deltas.
  static String? _extractTextFromGenerateContentChunk(dynamic obj) {
    // Full response shape (non-stream):
    // { candidates: [{ content: { parts: [{text: '...'}] } }] }
    // Stream responses may deliver similar fragments or deltas.
    if (obj is Map) {
      final cands = obj['candidates'];
      if (cands is List && cands.isNotEmpty) {
        final first = cands.first;
        if (first is Map) {
          final content = first['content'];
          // Newer responses: content: { role: 'model', parts: [...] }
          if (content is Map) {
            final parts = content['parts'];
            if (parts is List && parts.isNotEmpty) {
              // Concatenate any text parts in this chunk
              final buf = StringBuffer();
              for (final p in parts) {
                if (p is Map && p['text'] is String) {
                  buf.write(p['text']);
                }
              }
              final s = buf.toString();
              if (s.isNotEmpty) return s;
            }
          }

          // Some streamed fragments may include 'delta' with parts
          final delta = first['delta'];
          if (delta is Map) {
            final parts = delta['parts'];
            if (parts is List && parts.isNotEmpty) {
              final buf = StringBuffer();
              for (final p in parts) {
                if (p is Map && p['text'] is String) {
                  buf.write(p['text']);
                }
              }
              final s = buf.toString();
              if (s.isNotEmpty) return s;
            }
          }

          // Older fragments may include 'content' as list with {text:...}
          final contentList = first['content'];
          if (contentList is List && contentList.isNotEmpty) {
            final p0 = contentList.first;
            if (p0 is Map && p0['text'] is String) {
              return p0['text'] as String;
            }
          }
        }
      }

      // Single-delta chunk without candidates, e.g. { "text": "..." }
      if (obj['text'] is String) return obj['text'] as String;
    }
    return null;
  }
}

/* moved model classes to models.dart */