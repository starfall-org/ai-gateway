// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GitHubModel _$GitHubModelFromJson(Map<String, dynamic> json) => GitHubModel(
  id: json['id'] as String,
  name: json['name'] as String,
  supportedInputModalities:
      (json['supported_input_modalities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  supportedOutputModalities:
      (json['supported_output_modalities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  maxInputTokens: (json['max_input_tokens'] as num).toInt(),
  maxOutputTokens: (json['max_output_tokens'] as num).toInt(),
);

Map<String, dynamic> _$GitHubModelToJson(GitHubModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'supported_input_modalities': instance.supportedInputModalities,
      'supported_output_modalities': instance.supportedOutputModalities,
      'max_input_tokens': instance.maxInputTokens,
      'max_output_tokens': instance.maxOutputTokens,
    };
