import 'dart:io';

import 'package:llm/models/api/openai/responses.dart';
import 'package:llm/provider/openai/openai.dart';

void main() async {
  testOpenai();
}

void testOpenai() async {
  final openai = OpenAI(
    apiKey: Platform.environment['OPENAI_API_KEY'] ?? 'your_api_key_here',
    baseUrl: 'https://api.openai.com/v1',
  );
  final response = openai.responsesStream(
    OpenAiResponsesRequest.fromJson({
      "model": "gpt-5-nano",
      "stream": true,
      "input": [
        {"role": "user", "content": "Hello, how are you?"},
      ],
    }),
  );
  await for (final chunk in response) {
    print(chunk.toString());
  }
}
