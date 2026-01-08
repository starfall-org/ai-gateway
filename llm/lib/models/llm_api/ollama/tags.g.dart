// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OllamaTagsResponse _$OllamaTagsResponseFromJson(Map<String, dynamic> json) =>
    OllamaTagsResponse(
      models: (json['models'] as List<dynamic>)
          .map((e) => OllamaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OllamaTagsResponseToJson(OllamaTagsResponse instance) =>
    <String, dynamic>{
      'models': instance.models.map((e) => e.toJson()).toList(),
    };

OllamaModel _$OllamaModelFromJson(Map<String, dynamic> json) => OllamaModel(
  name: json['name'] as String,
  modifiedAt: json['modified_at'] as String?,
  size: (json['size'] as num?)?.toInt(),
  details: json['details'] == null
      ? null
      : OllamaModelDetails.fromJson(json['details'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OllamaModelToJson(OllamaModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'modified_at': instance.modifiedAt,
      'size': instance.size,
      'details': instance.details?.toJson(),
    };

OllamaModelDetails _$OllamaModelDetailsFromJson(Map<String, dynamic> json) =>
    OllamaModelDetails(
      format: json['format'] as String?,
      family: json['family'] as String?,
      families: (json['families'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parameterSize: json['parameter_size'] as String?,
      quantizationLevel: json['quantization_level'] as String?,
      parentId: json['parent_id'] as String?,
    );

Map<String, dynamic> _$OllamaModelDetailsToJson(OllamaModelDetails instance) =>
    <String, dynamic>{
      'format': instance.format,
      'family': instance.family,
      'families': instance.families,
      'parameter_size': instance.parameterSize,
      'quantization_level': instance.quantizationLevel,
      'parent_id': instance.parentId,
    };
