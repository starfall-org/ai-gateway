import 'package:json_annotation/json_annotation.dart';

part 'responses.g.dart';

// Response-related classes
@JsonSerializable()
class OpenAiResponses {
  final String id;
  final String object;
  @JsonKey(name: 'created_at')
  final int createdAt;
  final String model;
  final String status;
  final ErrorInfo? error;
  @JsonKey(name: 'incomplete_details')
  final IncompleteDetails? incompleteDetails;
  final List<ResponseItem> output;
  final ResponsesUsage usage;

  OpenAiResponses({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.model,
    required this.status,
    this.error,
    this.incompleteDetails,
    required this.output,
    required this.usage,
  });

  factory OpenAiResponses.fromJson(Map<String, dynamic> json) =>
      _$OpenAiResponsesFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiResponsesToJson(this);
}

@JsonSerializable()
class ResponseItem {
  final String id;
  final String type;
  final String role;
  final List<MessageContent> content;
  final String status;

  ResponseItem({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.status,
  });

  factory ResponseItem.fromJson(Map<String, dynamic> json) =>
      _$ResponseItemFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseItemToJson(this);
}

@JsonSerializable()
class MessageContent {
  final String type;
  final String text;
  final List<Annotation>? annotations;
  final Logprobs? logprobs;

  MessageContent({
    required this.type,
    required this.text,
    this.annotations,
    this.logprobs,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);

  Map<String, dynamic> toJson() => _$MessageContentToJson(this);
}

@JsonSerializable()
class Annotation {
  final String type;
  final String text;
  @JsonKey(name: 'start_index')
  final int startIndex;
  @JsonKey(name: 'end_index')
  final int endIndex;
  @JsonKey(name: 'file_id')
  final String? fileId;
  final String? title;

  Annotation({
    required this.type,
    required this.text,
    required this.startIndex,
    required this.endIndex,
    this.fileId,
    this.title,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) => _$AnnotationFromJson(json);

  Map<String, dynamic> toJson() => _$AnnotationToJson(this);
}

@JsonSerializable()
class Logprobs {
  final String token;
  final double logprob;
  final List<int> bytes;
  @JsonKey(name: 'top_logprobs')
  final List<TopLogprob> topLogprobs;

  Logprobs({
    required this.token,
    required this.logprob,
    required this.bytes,
    required this.topLogprobs,
  });

  factory Logprobs.fromJson(Map<String, dynamic> json) => _$LogprobsFromJson(json);

  Map<String, dynamic> toJson() => _$LogprobsToJson(this);
}

@JsonSerializable()
class TopLogprob {
  final String token;
  final double logprob;
  final List<int> bytes;

  TopLogprob({
    required this.token,
    required this.logprob,
    required this.bytes,
  });

  factory TopLogprob.fromJson(Map<String, dynamic> json) => _$TopLogprobFromJson(json);

  Map<String, dynamic> toJson() => _$TopLogprobToJson(this);
}

@JsonSerializable()
class ErrorInfo {
  final String code;
  final String message;

  ErrorInfo({
    required this.code,
    required this.message,
  });

  factory ErrorInfo.fromJson(Map<String, dynamic> json) => _$ErrorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorInfoToJson(this);
}

@JsonSerializable()
class IncompleteDetails {
  final String reason;
  final String type;

  IncompleteDetails({
    required this.reason,
    required this.type,
  });

  factory IncompleteDetails.fromJson(Map<String, dynamic> json) => _$IncompleteDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$IncompleteDetailsToJson(this);
}

@JsonSerializable()
class ResponsesUsage {
  @JsonKey(name: 'input_tokens')
  final int inputTokens;
  @JsonKey(name: 'output_tokens')
  final int outputTokens;
  @JsonKey(name: 'total_tokens')
  final int totalTokens;
  @JsonKey(name: 'input_tokens_details')
  final UsageDetails inputTokensDetails;
  @JsonKey(name: 'output_tokens_details')
  final UsageDetails outputTokensDetails;

  ResponsesUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.inputTokensDetails,
    required this.outputTokensDetails,
  });

  factory ResponsesUsage.fromJson(Map<String, dynamic> json) => _$ResponsesUsageFromJson(json);

  Map<String, dynamic> toJson() => _$ResponsesUsageToJson(this);
}

@JsonSerializable()
class UsageDetails {
  @JsonKey(name: 'cached_tokens')
  final int? cachedTokens;
  @JsonKey(name: 'text_tokens')
  final int? textTokens;
  @JsonKey(name: 'image_tokens')
  final int? imageTokens;
  @JsonKey(name: 'audio_tokens')
  final int? audioTokens;
  @JsonKey(name: 'reasoning_tokens')
  final int? reasoningTokens;

  UsageDetails({
    this.cachedTokens,
    this.textTokens,
    this.imageTokens,
    this.audioTokens,
    this.reasoningTokens,
  });

  factory UsageDetails.fromJson(Map<String, dynamic> json) => _$UsageDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageDetailsToJson(this);
}