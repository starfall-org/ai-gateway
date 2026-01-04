// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeminiModelsResponse _$GeminiModelsResponseFromJson(
  Map<String, dynamic> json,
) => GeminiModelsResponse(
  models: (json['models'] as List<dynamic>?)
      ?.map((e) => GeminiModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextPageToken: (json['next_page_token'] as num?)?.toInt(),
);

Map<String, dynamic> _$GeminiModelsResponseToJson(
  GeminiModelsResponse instance,
) => <String, dynamic>{
  'models': instance.models,
  'next_page_token': instance.nextPageToken,
};

GeminiModel _$GeminiModelFromJson(Map<String, dynamic> json) => GeminiModel(
  name: json['name'] as String?,
  displayName: json['display_name'] as String?,
  description: json['description'] as String?,
  version: json['version'] as String?,
  baseModelId: json['base_model_id'] as String?,
  capabilities: json['capabilities'] == null
      ? null
      : GeminiModelCapabilities.fromJson(
          json['capabilities'] as Map<String, dynamic>,
        ),
  input: json['input'] == null
      ? null
      : GeminiModelInput.fromJson(json['input'] as Map<String, dynamic>),
  output: json['output'] == null
      ? null
      : GeminiModelOutput.fromJson(json['output'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GeminiModelToJson(GeminiModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'display_name': instance.displayName,
      'description': instance.description,
      'version': instance.version,
      'base_model_id': instance.baseModelId,
      'capabilities': instance.capabilities,
      'input': instance.input,
      'output': instance.output,
    };

GeminiModelCapabilities _$GeminiModelCapabilitiesFromJson(
  Map<String, dynamic> json,
) => GeminiModelCapabilities(
  mediaUnderstanding: json['mediaUnderstanding'] as bool?,
  codeExecution: json['codeExecution'] as bool?,
  videoGeneration: json['videoGeneration'] as bool?,
  audioGeneration: json['audioGeneration'] as bool?,
  imageGeneration: json['imageGeneration'] as bool?,
);

Map<String, dynamic> _$GeminiModelCapabilitiesToJson(
  GeminiModelCapabilities instance,
) => <String, dynamic>{
  'mediaUnderstanding': instance.mediaUnderstanding,
  'codeExecution': instance.codeExecution,
  'videoGeneration': instance.videoGeneration,
  'audioGeneration': instance.audioGeneration,
  'imageGeneration': instance.imageGeneration,
};

GeminiModelInput _$GeminiModelInputFromJson(Map<String, dynamic> json) =>
    GeminiModelInput(
      type: json['type'] as String?,
      mimeType: (json['mimeType'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GeminiModelInputToJson(GeminiModelInput instance) =>
    <String, dynamic>{'type': instance.type, 'mimeType': instance.mimeType};

GeminiModelOutput _$GeminiModelOutputFromJson(Map<String, dynamic> json) =>
    GeminiModelOutput(
      type: json['type'] as String?,
      mimeType: (json['mimeType'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GeminiModelOutputToJson(GeminiModelOutput instance) =>
    <String, dynamic>{'type': instance.type, 'mimeType': instance.mimeType};
