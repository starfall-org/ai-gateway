// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicModel _$BasicModelFromJson(Map<String, dynamic> json) => BasicModel(
  id: json['id'] as String,
  displayName: json['display_name'] as String,
  ownedBy: json['owned_by'] as String,
);

Map<String, dynamic> _$BasicModelToJson(BasicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'owned_by': instance.ownedBy,
    };
