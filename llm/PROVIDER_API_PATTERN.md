# Provider API Pattern Migration

Đã cập nhật tất cả các provider để sử dụng pattern gọi API tương tự như OpenAI với các method riêng biệt cho từng endpoint.

## Pattern Mới (Theo OpenAI)

### OpenAI Provider
```dart
// Các method riêng biệt cho từng endpoint
Future<OpenAiChatCompletions> chatCompletions(OpenAiChatCompletionsRequest request)
Stream<OpenAiChatCompletions> chatCompletionsStream(OpenAiChatCompletionsRequest request)
Future<OpenAiImagesGenerations> imagesGenerations(OpenAiImagesGenerationsRequest request)
Future<OpenAiAudioSpeech> audioSpeech(OpenAiAudioSpeechRequest request)
Future<OpenAiVideos> videos(OpenAiVideosRequest request)
Future<OpenAiModels> listModels()
Future<OpenAiEmbeddings> embeddings({required OpenAiEmbeddingsRequest request})
```

### Anthropic Provider
```dart
// Áp dụng pattern tương tự
Future<AnthropicMessagesResponse> messages(AnthropicMessagesRequest request)
Stream<AnthropicMessagesResponse> messagesStream(AnthropicMessagesRequest request)
Future<AnthropicModels> listModels()
```

### Ollama Provider
```dart
// Áp dụng pattern tương tự
Future<OllamaChatResponse> chat(OllamaChatRequest request)
Stream<OllamaChatStreamResponse> chatStream(OllamaChatRequest request)
Future<OllamaTagsResponse> listModels()
Future<OllamaEmbedResponse> embeddings(OllamaEmbedRequest request)
```

### GoogleAI Provider
```dart
// Áp dụng pattern tương tự
Future<GeminiGenerateContentResponse> generateContent({required String model, required GeminiGenerateContentRequest request})
Stream<GeminiGenerateContentResponse> generateContentStream({required String model, required GeminiGenerateContentRequest request})
Future<GeminiEmbeddingsResponse> embedContent({required String model, required GeminiEmbeddingsRequest request})
Future<GeminiBatchEmbeddingsResponse> batchEmbedContents({required String model, required GeminiBatchEmbeddingsRequest request})
Future<GeminiModelsResponse> listModels({int? pageSize, String? pageToken})
Future<GeminiModel> getModel({required String model})
```

## Lợi ích của Pattern Mới

1. **Tính nhất quán**: Tất cả provider đều sử dụng cùng một pattern
2. **Type Safety**: Mỗi endpoint có request/response model riêng biệt
3. **Rõ ràng**: Tên method thể hiện rõ endpoint nào được gọi
4. **Dễ bảo trì**: Dễ dàng thêm/sửa endpoint mà không ảnh hưởng đến các endpoint khác
5. **Tương thích**: Có thể giữ lại các method legacy cho backward compatibility

## Các File Đã Tạo/Cập nhật

### Anthropic
- `llm/lib/models/api/anthropic/messages.dart` - Request/Response models cho messages endpoint
- `llm/lib/models/api/anthropic/messages.g.dart` - Generated code
- `llm/lib/provider/anthropic/anthropic.dart` - Provider với pattern mới

### Ollama
- `llm/lib/provider/ollama/ollama.dart` - Provider với pattern mới (sử dụng models có sẵn)

### GoogleAI
- `llm/lib/provider/googleai/aistudio.dart` - Provider với pattern mới (sử dụng models có sẵn)

### Base
- `llm/lib/provider/base.dart` - Đã cleanup imports không cần thiết

## Migration Notes

- Các provider cũ vẫn có thể hoạt động nếu có legacy methods
- Nên sử dụng các method mới cho code mới
- Các model request/response đã được định nghĩa đầy đủ với JsonSerializable
- Pattern này giúp dễ dàng mở rộng và bảo trì trong tương lai