// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'googleai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAiModel _$GoogleAiModelFromJson(Map<String, dynamic> json) =>
    GoogleAiModel(
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      inputTokenLimit: (json['input_token_limit'] as num).toInt(),
      outputTokenLimit: (json['output_token_limit'] as num).toInt(),
      supportedGenerationMethods:
          (json['supported_generation_methods'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      thinking: json['thinking'] as bool,
      temperature: (json['temperature'] as num).toDouble(),
      maxTemperature: (json['max_temperature'] as num).toDouble(),
      topP: (json['top_p'] as num).toDouble(),
      topK: (json['top_k'] as num).toInt(),
    );

Map<String, dynamic> _$GoogleAiModelToJson(GoogleAiModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'display_name': instance.displayName,
      'input_token_limit': instance.inputTokenLimit,
      'output_token_limit': instance.outputTokenLimit,
      'supported_generation_methods': instance.supportedGenerationMethods,
      'thinking': instance.thinking,
      'temperature': instance.temperature,
      'max_temperature': instance.maxTemperature,
      'top_p': instance.topP,
      'top_k': instance.topK,
    };
