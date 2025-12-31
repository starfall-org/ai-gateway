// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_speech.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAIAudioSpeechRequest _$OpenAIAudioSpeechRequestFromJson(
  Map<String, dynamic> json,
) => OpenAIAudioSpeechRequest(
  model: json['model'] as String,
  input: json['input'] as String,
  voice: json['voice'] as String,
  responseFormat: json['responseFormat'] == null
      ? null
      : OpenAIAudioResponseFormat.fromJson(json['responseFormat'] as String),
  speed: (json['speed'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OpenAIAudioSpeechRequestToJson(
  OpenAIAudioSpeechRequest instance,
) => <String, dynamic>{
  'model': instance.model,
  'input': instance.input,
  'voice': instance.voice,
  'responseFormat': instance.responseFormat,
  'speed': instance.speed,
};

OpenAIAudioSpeechResponse _$OpenAIAudioSpeechResponseFromJson(
  Map<String, dynamic> json,
) => OpenAIAudioSpeechResponse(audioContent: json['audio_content'] as String);

Map<String, dynamic> _$OpenAIAudioSpeechResponseToJson(
  OpenAIAudioSpeechResponse instance,
) => <String, dynamic>{'audio_content': instance.audioContent};
