import 'package:json_annotation/json_annotation.dart';

part 'messages.g.dart';

@JsonSerializable()
class AnthropicMessagesRequest {
  final String model;
  final List<AnthropicMessage> messages;
  @JsonKey(name: 'max_tokens')
  final int maxTokens;
  final String? system;
  final double? temperature;
  final List<AnthropicTool>? tools;
  @JsonKey(name: 'tool_choice')
  final dynamic toolChoice;
  final bool? stream;

  AnthropicMessagesRequest({
    required this.model,
    required this.messages,
    required this.maxTokens,
    this.system,
    this.temperature,
    this.tools,
    this.toolChoice,
    this.stream,
  });

  factory AnthropicMessagesRequest.fromJson(Map<String, dynamic> json) =>
      _$AnthropicMessagesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicMessagesRequestToJson(this);
}

@JsonSerializable()
class AnthropicMessage {
  final String role;
  final dynamic content; // String or List<AnthropicContent>

  AnthropicMessage({
    required this.role,
    required this.content,
  });

  factory AnthropicMessage.fromJson(Map<String, dynamic> json) =>
      _$AnthropicMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicMessageToJson(this);
}

@JsonSerializable()
class AnthropicContent {
  final String type;
  final String? text;
  final String? source;
  @JsonKey(name: 'media_type')
  final String? mediaType;
  final String? data;

  AnthropicContent({
    required this.type,
    this.text,
    this.source,
    this.mediaType,
    this.data,
  });

  factory AnthropicContent.fromJson(Map<String, dynamic> json) =>
      _$AnthropicContentFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicContentToJson(this);
}

@JsonSerializable()
class AnthropicTool {
  final String name;
  final String? description;
  @JsonKey(name: 'input_schema')
  final Map<String, dynamic> inputSchema;

  AnthropicTool({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  factory AnthropicTool.fromJson(Map<String, dynamic> json) =>
      _$AnthropicToolFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicToolToJson(this);
}

@JsonSerializable()
class AnthropicMessagesResponse {
  final String id;
  final String type;
  final String role;
  final List<AnthropicContent> content;
  final String model;
  @JsonKey(name: 'stop_reason')
  final String? stopReason;
  @JsonKey(name: 'stop_sequence')
  final String? stopSequence;
  final AnthropicUsage usage;

  AnthropicMessagesResponse({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.model,
    this.stopReason,
    this.stopSequence,
    required this.usage,
  });

  factory AnthropicMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$AnthropicMessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicMessagesResponseToJson(this);
}

@JsonSerializable()
class AnthropicUsage {
  @JsonKey(name: 'input_tokens')
  final int inputTokens;
  @JsonKey(name: 'output_tokens')
  final int outputTokens;

  AnthropicUsage({
    required this.inputTokens,
    required this.outputTokens,
  });

  factory AnthropicUsage.fromJson(Map<String, dynamic> json) =>
      _$AnthropicUsageFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicUsageToJson(this);
}