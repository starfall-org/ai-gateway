import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'i_tts_service.dart';

class OpenAITTS implements ITTSService {
  @override
  Future<Uint8List> synthesize(
    String text,
    String model,
    String? voiceId,
    Map<String, dynamic> settings, {
    String? apiKey,
    String? baseApiUrl,
  }) async {
    if (apiKey == null) {
      throw Exception('OpenAI API Key is required');
    }
    
    // Use baseApiUrl if provided, otherwise default. Removing trailing slash if present.
    final baseUrl = baseApiUrl?.replaceAll(RegExp(r'\/+$'), '') ?? 'https://api.openai.com/v1';
    final url = Uri.parse('$baseUrl/audio/speech');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'input': text,
        'voice': voiceId ?? 'alloy',
        'response_format': 'mp3',
        ...settings, // speed, etc.
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('OpenAI TTS Failed: ${response.statusCode} - ${response.body}');
    }
  }
}
