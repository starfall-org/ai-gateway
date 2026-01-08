// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OllamaChatRequest _$OllamaChatRequestFromJson(Map<String, dynamic> json) =>
    OllamaChatRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => OllamaMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      format: json['format'] as String?,
      options: json['options'] == null
          ? null
          : OllamaOptions.fromJson(json['options'] as Map<String, dynamic>),
      stream: json['stream'] as bool?,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => OllamaTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OllamaChatRequestToJson(OllamaChatRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'format': instance.format,
      'options': instance.options?.toJson(),
      'stream': instance.stream,
      'tools': instance.tools?.map((e) => e.toJson()).toList(),
    };

OllamaMessage _$OllamaMessageFromJson(Map<String, dynamic> json) =>
    OllamaMessage(
      role: json['role'] as String,
      content: json['content'],
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => OllamaImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolCalls: json['tool_calls'] == null
          ? null
          : OllamaToolCall.fromJson(json['tool_calls'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OllamaMessageToJson(OllamaMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'images': instance.images?.map((e) => e.toJson()).toList(),
      'tool_calls': instance.toolCalls?.toJson(),
    };

OllamaImage _$OllamaImageFromJson(Map<String, dynamic> json) =>
    OllamaImage(data: json['data'] as String);

Map<String, dynamic> _$OllamaImageToJson(OllamaImage instance) =>
    <String, dynamic>{'data': instance.data};

OllamaTool _$OllamaToolFromJson(Map<String, dynamic> json) => OllamaTool(
  function: OllamaFunction.fromJson(json['function'] as Map<String, dynamic>),
  type: json['type'] as String? ?? 'function',
);

Map<String, dynamic> _$OllamaToolToJson(OllamaTool instance) =>
    <String, dynamic>{
      'function': instance.function.toJson(),
      'type': instance.type,
    };

OllamaFunction _$OllamaFunctionFromJson(Map<String, dynamic> json) =>
    OllamaFunction(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$OllamaFunctionToJson(OllamaFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parameters': instance.parameters,
    };

OllamaToolCall _$OllamaToolCallFromJson(Map<String, dynamic> json) =>
    OllamaToolCall(
      function: OllamaToolCallFunction.fromJson(
        json['function'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$OllamaToolCallToJson(OllamaToolCall instance) =>
    <String, dynamic>{'function': instance.function.toJson()};

OllamaToolCallFunction _$OllamaToolCallFunctionFromJson(
  Map<String, dynamic> json,
) => OllamaToolCallFunction(
  name: json['name'] as String,
  arguments: json['arguments'] as Map<String, dynamic>,
);

Map<String, dynamic> _$OllamaToolCallFunctionToJson(
  OllamaToolCallFunction instance,
) => <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

OllamaOptions _$OllamaOptionsFromJson(Map<String, dynamic> json) =>
    OllamaOptions(
      numCtx: (json['num_ctx'] as num?)?.toInt(),
      numBatch: (json['num_batch'] as num?)?.toInt(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topK: (json['top_k'] as num?)?.toInt(),
      topP: (json['top_p'] as num?)?.toDouble(),
      numGqa: (json['num_gqa'] as num?)?.toInt(),
      numGpu: (json['num_gpu'] as num?)?.toInt(),
      numThread: (json['num_thread'] as num?)?.toInt(),
      seed: (json['seed'] as num?)?.toInt(),
      useMmap: json['use_mmap'] as bool?,
      useMlock: json['use_mlock'] as bool?,
      repeatLastN: (json['repeat_last_n'] as num?)?.toDouble(),
      repeatPenalty: (json['repeat_penalty'] as num?)?.toDouble(),
      presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
      frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
      dryMultiplier: (json['dry_multiplier'] as num?)?.toDouble(),
      dryBase: (json['dry_base'] as num?)?.toDouble(),
      dryAllowedLength: (json['dry_allowed_length'] as num?)?.toInt(),
      drySpecialTokens: (json['dry_special_tokens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      numPredict: (json['num_predict'] as num?)?.toInt(),
      stop: (json['stop'] as num?)?.toInt(),
      tfsZ: (json['tfs_z'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      typicalP: (json['typical_p'] as num?)?.toInt(),
      penaltyLastN: (json['penalty_last_n'] as num?)?.toInt(),
      mirostat: (json['mirostat'] as num?)?.toInt(),
      mirostatTau: (json['mirostat_tau'] as num?)?.toDouble(),
      mirostatEta: (json['mirostat_eta'] as num?)?.toDouble(),
      penalizeNewline: (json['penalize_newline'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OllamaOptionsToJson(OllamaOptions instance) =>
    <String, dynamic>{
      'num_ctx': instance.numCtx,
      'num_batch': instance.numBatch,
      'temperature': instance.temperature,
      'top_k': instance.topK,
      'top_p': instance.topP,
      'num_gqa': instance.numGqa,
      'num_gpu': instance.numGpu,
      'num_thread': instance.numThread,
      'seed': instance.seed,
      'use_mmap': instance.useMmap,
      'use_mlock': instance.useMlock,
      'repeat_last_n': instance.repeatLastN,
      'repeat_penalty': instance.repeatPenalty,
      'presence_penalty': instance.presencePenalty,
      'frequency_penalty': instance.frequencyPenalty,
      'dry_multiplier': instance.dryMultiplier,
      'dry_base': instance.dryBase,
      'dry_allowed_length': instance.dryAllowedLength,
      'dry_special_tokens': instance.drySpecialTokens,
      'num_predict': instance.numPredict,
      'stop': instance.stop,
      'tfs_z': instance.tfsZ,
      'typical_p': instance.typicalP,
      'penalty_last_n': instance.penaltyLastN,
      'mirostat': instance.mirostat,
      'mirostat_tau': instance.mirostatTau,
      'mirostat_eta': instance.mirostatEta,
      'penalize_newline': instance.penalizeNewline,
    };

OllamaChatResponse _$OllamaChatResponseFromJson(Map<String, dynamic> json) =>
    OllamaChatResponse(
      model: json['model'] as String,
      createdAt: json['created_at'] as String,
      message: OllamaMessage.fromJson(json['message'] as Map<String, dynamic>),
      done: json['done'] as bool,
      totalDuration: (json['total_duration'] as num?)?.toInt(),
      loadDuration: (json['load_duration'] as num?)?.toInt(),
      promptEvalCount: (json['prompt_eval_count'] as num?)?.toInt(),
      promptEvalDuration: (json['prompt_eval_duration'] as num?)?.toInt(),
      evalCount: (json['eval_count'] as num?)?.toInt(),
      evalDuration: (json['eval_duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OllamaChatResponseToJson(OllamaChatResponse instance) =>
    <String, dynamic>{
      'model': instance.model,
      'created_at': instance.createdAt,
      'message': instance.message.toJson(),
      'done': instance.done,
      'total_duration': instance.totalDuration,
      'load_duration': instance.loadDuration,
      'prompt_eval_count': instance.promptEvalCount,
      'prompt_eval_duration': instance.promptEvalDuration,
      'eval_count': instance.evalCount,
      'eval_duration': instance.evalDuration,
    };

OllamaChatStreamResponse _$OllamaChatStreamResponseFromJson(
  Map<String, dynamic> json,
) => OllamaChatStreamResponse(
  model: json['model'] as String?,
  createdAt: json['created_at'] as String?,
  message: json['message'] == null
      ? null
      : OllamaMessage.fromJson(json['message'] as Map<String, dynamic>),
  done: json['done'] as bool?,
  totalDuration: (json['total_duration'] as num?)?.toInt(),
  loadDuration: (json['load_duration'] as num?)?.toInt(),
  promptEvalCount: (json['prompt_eval_count'] as num?)?.toInt(),
  promptEvalDuration: (json['prompt_eval_duration'] as num?)?.toInt(),
  evalCount: (json['eval_count'] as num?)?.toInt(),
  evalDuration: (json['eval_duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$OllamaChatStreamResponseToJson(
  OllamaChatStreamResponse instance,
) => <String, dynamic>{
  'model': instance.model,
  'created_at': instance.createdAt,
  'message': instance.message?.toJson(),
  'done': instance.done,
  'total_duration': instance.totalDuration,
  'load_duration': instance.loadDuration,
  'prompt_eval_count': instance.promptEvalCount,
  'prompt_eval_duration': instance.promptEvalDuration,
  'eval_count': instance.evalCount,
  'eval_duration': instance.evalDuration,
};
