// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_cache_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationCacheEntry _$TranslationCacheEntryFromJson(
        Map<String, dynamic> json) =>
    TranslationCacheEntry(
      originalText: json['original_text'] as String,
      translatedText: json['translated_text'] as String,
      sourceLanguage: json['source_language'] as String,
      targetLanguage: json['target_language'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$TranslationCacheEntryToJson(
        TranslationCacheEntry instance) =>
    <String, dynamic>{
      'original_text': instance.originalText,
      'translated_text': instance.translatedText,
      'source_language': instance.sourceLanguage,
      'target_language': instance.targetLanguage,
      'timestamp': instance.timestamp.toIso8601String(),
    };
