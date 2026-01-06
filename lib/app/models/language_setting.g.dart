// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageSetting _$LanguageSettingFromJson(Map<String, dynamic> json) =>
    LanguageSetting(
      languageCode: json['language_code'] as String,
      countryCode: json['country_code'] as String?,
      autoDetect: json['auto_detect'] as bool? ?? true,
    );

Map<String, dynamic> _$LanguageSettingToJson(LanguageSetting instance) =>
    <String, dynamic>{
      'language_code': instance.languageCode,
      'country_code': instance.countryCode,
      'auto_detect': instance.autoDetect,
    };
