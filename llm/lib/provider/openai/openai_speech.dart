import 'dart:convert';

import 'package:http/http.dart' as http;

import '../base.dart';
import '../../../utils.dart';

mixin OpenAISpeech on AIBaseApi {
  String get audioSpeechPath;

  Future<AIResponse> audioSpeech(AIRequest request) async {
    final inputText =
        (request.extra['input'] as String?) ??
        request.messages
            .map((m) => ensureTextFromContent(m.content))
            .where((s) => s.trim().isNotEmpty)
            .join('\n');
    final voice = (request.extra['voice'] as String?) ?? 'alloy';
    final responseFormat =
        (request.extra['response_format'] as String?) ?? 'mp3';
    final accept = responseFormat == 'wav' ? 'audio/wav' : 'audio/mpeg';

    final body = <String, dynamic>{
      'model': request.model,
      'input': inputText,
      'voice': voice,
      'response_format': responseFormat,
      ...request.extra,
    };

    final res = await http.post(
      uri(audioSpeechPath),
      headers: getHeaders(overrides: {'Accept': accept}),
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final bytes = res.bodyBytes;
      final b64 = base64Encode(bytes);
      final content = AIContent(
        type: AIContentType.audio,
        dataBase64: b64,
        mimeType: accept,
      );
      return AIResponse(
        text: '',
        contents: [content],
        raw: {'content_type': accept},
      );
    }
    throw Exception(
      'OpenAI audio speech error ${res.statusCode}: ${res.body}',
    );
  }
}
