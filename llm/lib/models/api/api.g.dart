// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIContent _$AIContentFromJson(Map<String, dynamic> json) => AIContent(
  type: $enumDecode(_$AIContentTypeEnumMap, json['type']),
  text: json['text'] as String?,
  uri: json['uri'] as String?,
  filePath: json['file_path'] as String?,
  mimeType: json['mime_type'] as String?,
  dataBase64: json['data_base64'] as String?,
);

Map<String, dynamic> _$AIContentToJson(AIContent instance) => <String, dynamic>{
  'type': _$AIContentTypeEnumMap[instance.type]!,
  'text': instance.text,
  'uri': instance.uri,
  'file_path': instance.filePath,
  'mime_type': instance.mimeType,
  'data_base64': instance.dataBase64,
};

const _$AIContentTypeEnumMap = {
  AIContentType.text: 'text',
  AIContentType.image: 'image',
  AIContentType.audio: 'audio',
  AIContentType.video: 'video',
};

AIToolFunction _$AIToolFunctionFromJson(Map<String, dynamic> json) =>
    AIToolFunction(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AIToolFunctionToJson(AIToolFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parameters': instance.parameters,
    };

AIToolCall _$AIToolCallFromJson(Map<String, dynamic> json) => AIToolCall(
  id: json['id'] as String,
  name: json['name'] as String,
  arguments: json['arguments'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AIToolCallToJson(AIToolCall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'arguments': instance.arguments,
    };

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) => AIMessage(
  role: json['role'] as String,
  content: (json['content'] as List<dynamic>)
      .map((e) => AIContent.fromJson(e as Map<String, dynamic>))
      .toList(),
  name: json['name'] as String?,
  toolCallId: json['tool_call_id'] as String?,
);

Map<String, dynamic> _$AIMessageToJson(AIMessage instance) => <String, dynamic>{
  'role': instance.role,
  'content': instance.content.map((e) => e.toJson()).toList(),
  'name': instance.name,
  'tool_call_id': instance.toolCallId,
};

AIRequest _$AIRequestFromJson(Map<String, dynamic> json) => AIRequest(
  model: json['model'] as String,
  messages: (json['messages'] as List<dynamic>)
      .map((e) => AIMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  tools:
      (json['tools'] as List<dynamic>?)
          ?.map((e) => AIToolFunction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  toolChoice: json['tool_choice'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => AIContent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  audios:
      (json['audios'] as List<dynamic>?)
          ?.map((e) => AIContent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => AIContent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  temperature: (json['temperature'] as num?)?.toDouble(),
  maxTokens: (json['max_tokens'] as num?)?.toInt(),
  stream: json['stream'] as bool? ?? false,
  extra: json['extra'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AIRequestToJson(AIRequest instance) => <String, dynamic>{
  'model': instance.model,
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'tools': instance.tools.map((e) => e.toJson()).toList(),
  'tool_choice': instance.toolChoice,
  'images': instance.images.map((e) => e.toJson()).toList(),
  'audios': instance.audios.map((e) => e.toJson()).toList(),
  'files': instance.files.map((e) => e.toJson()).toList(),
  'temperature': instance.temperature,
  'max_tokens': instance.maxTokens,
  'stream': instance.stream,
  'extra': instance.extra,
};

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) => AIResponse(
  text: json['text'] as String,
  toolCalls:
      (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => AIToolCall.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  finishReason: json['finish_reason'] as String?,
  contents:
      (json['contents'] as List<dynamic>?)
          ?.map((e) => AIContent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  reasoningContent: json['reasoning_content'] as String?,
  raw: json['raw'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AIResponseToJson(AIResponse instance) =>
    <String, dynamic>{
      'text': instance.text,
      'tool_calls': instance.toolCalls.map((e) => e.toJson()).toList(),
      'finish_reason': instance.finishReason,
      'contents': instance.contents.map((e) => e.toJson()).toList(),
      'reasoning_content': instance.reasoningContent,
      'raw': instance.raw,
    };
