// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnthropicModels _$AnthropicModelsFromJson(Map<String, dynamic> json) =>
    AnthropicModels(
      data: (json['data'] as List<dynamic>)
          .map((e) => BasicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['firstId'] as String,
      hasMore: json['hasMore'] as bool,
      lastId: json['lastId'] as String,
    );

Map<String, dynamic> _$AnthropicModelsToJson(AnthropicModels instance) =>
    <String, dynamic>{
      'data': instance.data,
      'firstId': instance.firstId,
      'hasMore': instance.hasMore,
      'lastId': instance.lastId,
    };
