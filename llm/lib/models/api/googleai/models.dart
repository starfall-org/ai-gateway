import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

// Response Models for listModels endpoint
@JsonSerializable()
class GeminiModelsResponse {
  final List<GeminiModel>? models;
  @JsonKey(name: 'next_page_token')
  final int? nextPageToken;

  GeminiModelsResponse({
    this.models,
    this.nextPageToken,
  });

  factory GeminiModelsResponse.fromJson(Map<String, dynamic> json) =>
      _$GeminiModelsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiModelsResponseToJson(this);
}

@JsonSerializable()
class GeminiModel {
  final String? name;
  @JsonKey(name: 'display_name')
  final String? displayName;
  final String? description;
  final String? version;
  @JsonKey(name: 'base_model_id')
  final String? baseModelId;
  final GeminiModelCapabilities? capabilities;
  final GeminiModelInput? input;
  final GeminiModelOutput? output;

  GeminiModel({
    this.name,
    this.displayName,
    this.description,
    this.version,
    this.baseModelId,
    this.capabilities,
    this.input,
    this.output,
  });

  factory GeminiModel.fromJson(Map<String, dynamic> json) =>
      _$GeminiModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiModelToJson(this);
}

@JsonSerializable()
class GeminiModelCapabilities {
  final bool? mediaUnderstanding;
  final bool? codeExecution;
  final bool? videoGeneration;
  final bool? audioGeneration;
  final bool? imageGeneration;

  GeminiModelCapabilities({
    this.mediaUnderstanding,
    this.codeExecution,
    this.videoGeneration,
    this.audioGeneration,
    this.imageGeneration,
  });

  factory GeminiModelCapabilities.fromJson(Map<String, dynamic> json) =>
      _$GeminiModelCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiModelCapabilitiesToJson(this);
}

@JsonSerializable()
class GeminiModelInput {
  final String? type;
  final List<String>? mimeType;

  GeminiModelInput({
    this.type,
    this.mimeType,
  });

  factory GeminiModelInput.fromJson(Map<String, dynamic> json) =>
      _$GeminiModelInputFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiModelInputToJson(this);
}

@JsonSerializable()
class GeminiModelOutput {
  final String? type;
  final List<String>? mimeType;

  GeminiModelOutput({
    this.type,
    this.mimeType,
  });

  factory GeminiModelOutput.fromJson(Map<String, dynamic> json) =>
      _$GeminiModelOutputFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiModelOutputToJson(this);
}
