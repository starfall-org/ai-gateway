// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ollama_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OllamaModel _$OllamaModelFromJson(Map<String, dynamic> json) => OllamaModel(
  name: json['name'] as String,
  model: json['model'] as String,
  parameterSize: json['parameter_size'] as String,
  quantizationLevel: json['quantization_level'] as String,
);

Map<String, dynamic> _$OllamaModelToJson(OllamaModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'model': instance.model,
      'parameter_size': instance.parameterSize,
      'quantization_level': instance.quantizationLevel,
    };
