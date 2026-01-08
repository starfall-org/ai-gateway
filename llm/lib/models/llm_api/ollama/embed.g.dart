// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OllamaEmbedRequest _$OllamaEmbedRequestFromJson(Map<String, dynamic> json) =>
    OllamaEmbedRequest(
      model: json['model'] as String,
      input: json['input'] as String,
      options: json['options'] == null
          ? null
          : OllamaEmbedOptions.fromJson(
              json['options'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$OllamaEmbedRequestToJson(OllamaEmbedRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'input': instance.input,
      'options': instance.options?.toJson(),
    };

OllamaEmbedOptions _$OllamaEmbedOptionsFromJson(Map<String, dynamic> json) =>
    OllamaEmbedOptions(
      numCtx: (json['num_ctx'] as num?)?.toInt(),
      numBatch: (json['num_batch'] as num?)?.toInt(),
      numGqa: (json['num_gqa'] as num?)?.toInt(),
      numGpu: (json['num_gpu'] as num?)?.toInt(),
      numThread: (json['num_thread'] as num?)?.toInt(),
      seed: (json['seed'] as num?)?.toInt(),
      useMmap: json['use_mmap'] as bool?,
      useMlock: json['use_mlock'] as bool?,
      f16Kv: (json['f16_kv'] as num?)?.toInt(),
      logitsAll: (json['logits_all'] as num?)?.toInt(),
      vocabOnly: (json['vocab_only'] as num?)?.toInt(),
      ropeFrequencyBase: json['rope_frequency_base'] as bool?,
      ropeFrequencyScale: json['rope_frequency_scale'] as bool?,
      numPredict: (json['num_predict'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OllamaEmbedOptionsToJson(OllamaEmbedOptions instance) =>
    <String, dynamic>{
      'num_ctx': instance.numCtx,
      'num_batch': instance.numBatch,
      'num_gqa': instance.numGqa,
      'num_gpu': instance.numGpu,
      'num_thread': instance.numThread,
      'seed': instance.seed,
      'use_mmap': instance.useMmap,
      'use_mlock': instance.useMlock,
      'f16_kv': instance.f16Kv,
      'logits_all': instance.logitsAll,
      'vocab_only': instance.vocabOnly,
      'rope_frequency_base': instance.ropeFrequencyBase,
      'rope_frequency_scale': instance.ropeFrequencyScale,
      'num_predict': instance.numPredict,
    };

OllamaEmbedResponse _$OllamaEmbedResponseFromJson(Map<String, dynamic> json) =>
    OllamaEmbedResponse(
      model: json['model'] as String,
      embedding: (json['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$OllamaEmbedResponseToJson(
  OllamaEmbedResponse instance,
) => <String, dynamic>{
  'model': instance.model,
  'embedding': instance.embedding,
};
