// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiChatCompletionRequest _$OpenAiChatCompletionRequestFromJson(
  Map<String, dynamic> json,
) => OpenAiChatCompletionRequest(
  model: json['model'] as String,
  messages: (json['messages'] as List<dynamic>)
      .map((e) => RequestMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  topLogprobs: (json['topLogprobs'] as num?)?.toInt(),
  temperature: (json['temperature'] as num?)?.toDouble(),
  topP: (json['topP'] as num?)?.toDouble(),
  user: json['user'] as String?,
  safetyIdentifier: json['safetyIdentifier'] as String?,
  promptCacheKey: json['promptCacheKey'] as String?,
  serviceTier: json['serviceTier'] as String?,
  modalities: (json['modalities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  verbosity: json['verbosity'] as String?,
  reasoningEffort: json['reasoningEffort'] as String?,
  maxCompletionTokens: (json['maxCompletionTokens'] as num?)?.toInt(),
  frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble(),
  presencePenalty: (json['presencePenalty'] as num?)?.toDouble(),
  webSearchOptions: json['webSearchOptions'] == null
      ? null
      : WebSearchOptions.fromJson(
          json['webSearchOptions'] as Map<String, dynamic>,
        ),
  responseFormat: json['responseFormat'] == null
      ? null
      : ResponseFormat.fromJson(json['responseFormat'] as Map<String, dynamic>),
  audio: json['audio'] == null
      ? null
      : AudioConfig.fromJson(json['audio'] as Map<String, dynamic>),
  store: json['store'] as bool?,
  stream: json['stream'] as bool?,
  stop: json['stop'] as String?,
  logitBias: json['logitBias'] as Map<String, dynamic>?,
  logprobs: json['logprobs'] as bool?,
  maxTokens: (json['maxTokens'] as num?)?.toInt(),
  n: (json['n'] as num?)?.toInt(),
  prediction: json['prediction'] == null
      ? null
      : Prediction.fromJson(json['prediction'] as Map<String, dynamic>),
  seed: (json['seed'] as num?)?.toInt(),
  streamOptions: json['streamOptions'] == null
      ? null
      : StreamOptions.fromJson(json['streamOptions'] as Map<String, dynamic>),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
      .toList(),
  toolChoice: json['toolChoice'] as String?,
  parallelToolCalls: json['parallelToolCalls'] as bool?,
  functionCall: json['functionCall'] as String?,
  functions: (json['functions'] as List<dynamic>?)
      ?.map((e) => FunctionDefinition.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpenAiChatCompletionRequestToJson(
  OpenAiChatCompletionRequest instance,
) => <String, dynamic>{
  'model': instance.model,
  'messages': instance.messages,
  'metadata': instance.metadata,
  'topLogprobs': instance.topLogprobs,
  'temperature': instance.temperature,
  'topP': instance.topP,
  'user': instance.user,
  'safetyIdentifier': instance.safetyIdentifier,
  'promptCacheKey': instance.promptCacheKey,
  'serviceTier': instance.serviceTier,
  'modalities': instance.modalities,
  'verbosity': instance.verbosity,
  'reasoningEffort': instance.reasoningEffort,
  'maxCompletionTokens': instance.maxCompletionTokens,
  'frequencyPenalty': instance.frequencyPenalty,
  'presencePenalty': instance.presencePenalty,
  'webSearchOptions': instance.webSearchOptions,
  'responseFormat': instance.responseFormat,
  'audio': instance.audio,
  'store': instance.store,
  'stream': instance.stream,
  'stop': instance.stop,
  'logitBias': instance.logitBias,
  'logprobs': instance.logprobs,
  'maxTokens': instance.maxTokens,
  'n': instance.n,
  'prediction': instance.prediction,
  'seed': instance.seed,
  'streamOptions': instance.streamOptions,
  'tools': instance.tools,
  'toolChoice': instance.toolChoice,
  'parallelToolCalls': instance.parallelToolCalls,
  'functionCall': instance.functionCall,
  'functions': instance.functions,
};

RequestMessage _$RequestMessageFromJson(Map<String, dynamic> json) =>
    RequestMessage(
      role: json['role'] as String,
      content: json['content'],
      name: json['name'] as String?,
    );

Map<String, dynamic> _$RequestMessageToJson(RequestMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'name': instance.name,
    };

WebSearchOptions _$WebSearchOptionsFromJson(Map<String, dynamic> json) =>
    WebSearchOptions(
      userLocation: json['userLocation'] == null
          ? null
          : UserLocation.fromJson(json['userLocation'] as Map<String, dynamic>),
      searchContextSize: json['searchContextSize'] as String?,
    );

Map<String, dynamic> _$WebSearchOptionsToJson(WebSearchOptions instance) =>
    <String, dynamic>{
      'userLocation': instance.userLocation,
      'searchContextSize': instance.searchContextSize,
    };

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
  type: json['type'] as String,
  approximate: ApproximateLocation.fromJson(
    json['approximate'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'approximate': instance.approximate,
    };

ApproximateLocation _$ApproximateLocationFromJson(Map<String, dynamic> json) =>
    ApproximateLocation(
      country: json['country'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$ApproximateLocationToJson(
  ApproximateLocation instance,
) => <String, dynamic>{
  'country': instance.country,
  'region': instance.region,
  'city': instance.city,
  'timezone': instance.timezone,
};

ResponseFormat _$ResponseFormatFromJson(Map<String, dynamic> json) =>
    ResponseFormat(type: json['type'] as String);

Map<String, dynamic> _$ResponseFormatToJson(ResponseFormat instance) =>
    <String, dynamic>{'type': instance.type};

AudioConfig _$AudioConfigFromJson(Map<String, dynamic> json) => AudioConfig(
  voice: json['voice'] as String,
  format: json['format'] as String,
);

Map<String, dynamic> _$AudioConfigToJson(AudioConfig instance) =>
    <String, dynamic>{'voice': instance.voice, 'format': instance.format};

Prediction _$PredictionFromJson(Map<String, dynamic> json) => Prediction(
  type: json['type'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{'type': instance.type, 'content': instance.content};

StreamOptions _$StreamOptionsFromJson(Map<String, dynamic> json) =>
    StreamOptions(
      includeUsage: json['includeUsage'] as bool?,
      includeObfuscation: json['includeObfuscation'] as bool?,
    );

Map<String, dynamic> _$StreamOptionsToJson(StreamOptions instance) =>
    <String, dynamic>{
      'includeUsage': instance.includeUsage,
      'includeObfuscation': instance.includeObfuscation,
    };

Tool _$ToolFromJson(Map<String, dynamic> json) => Tool(
  type: json['type'] as String,
  function: FunctionDefinition.fromJson(
    json['function'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
  'type': instance.type,
  'function': instance.function,
};

FunctionDefinition _$FunctionDefinitionFromJson(Map<String, dynamic> json) =>
    FunctionDefinition(
      description: json['description'] as String?,
      name: json['name'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
      strict: json['strict'] as bool?,
    );

Map<String, dynamic> _$FunctionDefinitionToJson(FunctionDefinition instance) =>
    <String, dynamic>{
      'description': instance.description,
      'name': instance.name,
      'parameters': instance.parameters,
      'strict': instance.strict,
    };

OpenAiChatCompletion _$OpenAiChatCompletionFromJson(
  Map<String, dynamic> json,
) => OpenAiChatCompletion(
  id: json['id'] as String?,
  object: json['object'] as String?,
  created: (json['created'] as num?)?.toInt(),
  model: json['model'] as String?,
  choices: (json['choices'] as List<dynamic>?)
      ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
  usage: json['usage'] == null
      ? null
      : ChatCompletionUsage.fromJson(json['usage'] as Map<String, dynamic>),
  systemFingerprint: json['systemFingerprint'] as String?,
  serviceTier: json['serviceTier'] as String?,
);

Map<String, dynamic> _$OpenAiChatCompletionToJson(
  OpenAiChatCompletion instance,
) => <String, dynamic>{
  'id': instance.id,
  'object': instance.object,
  'created': instance.created,
  'model': instance.model,
  'choices': instance.choices,
  'usage': instance.usage,
  'systemFingerprint': instance.systemFingerprint,
  'serviceTier': instance.serviceTier,
};

Choice _$ChoiceFromJson(Map<String, dynamic> json) => Choice(
  index: (json['index'] as num?)?.toInt(),
  message: json['message'] == null
      ? null
      : Message.fromJson(json['message'] as Map<String, dynamic>),
  delta: json['delta'] == null
      ? null
      : Delta.fromJson(json['delta'] as Map<String, dynamic>),
  finishReason: json['finishReason'] as String?,
  logprobs: json['logprobs'] == null
      ? null
      : Logprobs.fromJson(json['logprobs'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
  'index': instance.index,
  'message': instance.message,
  'delta': instance.delta,
  'finishReason': instance.finishReason,
  'logprobs': instance.logprobs,
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  content: json['content'] as String?,
  refusal: json['refusal'] as String?,
  role: json['role'] as String,
  functionCall: json['functionCall'] == null
      ? null
      : FunctionCall.fromJson(json['functionCall'] as Map<String, dynamic>),
  toolCalls: (json['toolCalls'] as List<dynamic>?)
      ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
      .toList(),
  annotations: (json['annotations'] as List<dynamic>?)
      ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
      .toList(),
  audio: json['audio'] == null
      ? null
      : Audio.fromJson(json['audio'] as Map<String, dynamic>),
  reasoningContent: json['reasoningContent'] as String?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'content': instance.content,
  'refusal': instance.refusal,
  'role': instance.role,
  'functionCall': instance.functionCall,
  'toolCalls': instance.toolCalls,
  'annotations': instance.annotations,
  'audio': instance.audio,
  'reasoningContent': instance.reasoningContent,
};

Delta _$DeltaFromJson(Map<String, dynamic> json) => Delta(
  content: json['content'] as String?,
  role: json['role'] as String?,
  refusal: json['refusal'] as String?,
  functionCall: json['functionCall'] == null
      ? null
      : FunctionCall.fromJson(json['functionCall'] as Map<String, dynamic>),
  toolCalls: (json['toolCalls'] as List<dynamic>?)
      ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DeltaToJson(Delta instance) => <String, dynamic>{
  'content': instance.content,
  'role': instance.role,
  'refusal': instance.refusal,
  'functionCall': instance.functionCall,
  'toolCalls': instance.toolCalls,
};

ToolCall _$ToolCallFromJson(Map<String, dynamic> json) => ToolCall(
  id: json['id'] as String?,
  type: json['type'] as String?,
  function: json['function'] == null
      ? null
      : FunctionCall.fromJson(json['function'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ToolCallToJson(ToolCall instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'function': instance.function,
};

FunctionCall _$FunctionCallFromJson(Map<String, dynamic> json) => FunctionCall(
  name: json['name'] as String?,
  arguments: json['arguments'] as String?,
);

Map<String, dynamic> _$FunctionCallToJson(FunctionCall instance) =>
    <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

Annotation _$AnnotationFromJson(Map<String, dynamic> json) => Annotation(
  type: json['type'] as String?,
  urlCitation: json['urlCitation'] == null
      ? null
      : UrlCitation.fromJson(json['urlCitation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnnotationToJson(Annotation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'urlCitation': instance.urlCitation,
    };

UrlCitation _$UrlCitationFromJson(Map<String, dynamic> json) => UrlCitation(
  endIndex: (json['endIndex'] as num?)?.toInt(),
  startIndex: (json['startIndex'] as num?)?.toInt(),
  url: json['url'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$UrlCitationToJson(UrlCitation instance) =>
    <String, dynamic>{
      'endIndex': instance.endIndex,
      'startIndex': instance.startIndex,
      'url': instance.url,
      'title': instance.title,
    };

Audio _$AudioFromJson(Map<String, dynamic> json) => Audio(
  id: json['id'] as String?,
  expiresAt: (json['expiresAt'] as num?)?.toInt(),
  data: json['data'] as String?,
  transcript: json['transcript'] as String?,
);

Map<String, dynamic> _$AudioToJson(Audio instance) => <String, dynamic>{
  'id': instance.id,
  'expiresAt': instance.expiresAt,
  'data': instance.data,
  'transcript': instance.transcript,
};

Logprobs _$LogprobsFromJson(Map<String, dynamic> json) => Logprobs(
  content: (json['content'] as List<dynamic>?)
      ?.map((e) => Token.fromJson(e as Map<String, dynamic>))
      .toList(),
  refusal: (json['refusal'] as List<dynamic>?)
      ?.map((e) => Token.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LogprobsToJson(Logprobs instance) => <String, dynamic>{
  'content': instance.content,
  'refusal': instance.refusal,
};

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
  token: json['token'] as String?,
  logprob: (json['logprob'] as num?)?.toDouble(),
  bytes: (json['bytes'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  topLogprobs: (json['topLogprobs'] as List<dynamic>?)
      ?.map((e) => TopLogprob.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'token': instance.token,
  'logprob': instance.logprob,
  'bytes': instance.bytes,
  'topLogprobs': instance.topLogprobs,
};

TopLogprob _$TopLogprobFromJson(Map<String, dynamic> json) => TopLogprob(
  token: json['token'] as String?,
  logprob: (json['logprob'] as num?)?.toDouble(),
  bytes: (json['bytes'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$TopLogprobToJson(TopLogprob instance) =>
    <String, dynamic>{
      'token': instance.token,
      'logprob': instance.logprob,
      'bytes': instance.bytes,
    };

ChatCompletionUsage _$ChatCompletionUsageFromJson(Map<String, dynamic> json) =>
    ChatCompletionUsage(
      promptTokens: (json['promptTokens'] as num?)?.toInt(),
      completionTokens: (json['completionTokens'] as num?)?.toInt(),
      totalTokens: (json['totalTokens'] as num?)?.toInt(),
      completionTokensDetails: json['completionTokensDetails'] == null
          ? null
          : CompletionTokenDetails.fromJson(
              json['completionTokensDetails'] as Map<String, dynamic>,
            ),
      promptTokensDetails: json['promptTokensDetails'] == null
          ? null
          : PromptTokenDetails.fromJson(
              json['promptTokensDetails'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ChatCompletionUsageToJson(
  ChatCompletionUsage instance,
) => <String, dynamic>{
  'promptTokens': instance.promptTokens,
  'completionTokens': instance.completionTokens,
  'totalTokens': instance.totalTokens,
  'completionTokensDetails': instance.completionTokensDetails,
  'promptTokensDetails': instance.promptTokensDetails,
};

PromptTokenDetails _$PromptTokenDetailsFromJson(Map<String, dynamic> json) =>
    PromptTokenDetails(
      cachedTokens: (json['cachedTokens'] as num?)?.toInt(),
      audioTokens: (json['audioTokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PromptTokenDetailsToJson(PromptTokenDetails instance) =>
    <String, dynamic>{
      'cachedTokens': instance.cachedTokens,
      'audioTokens': instance.audioTokens,
    };

CompletionTokenDetails _$CompletionTokenDetailsFromJson(
  Map<String, dynamic> json,
) => CompletionTokenDetails(
  reasoningTokens: (json['reasoningTokens'] as num?)?.toInt(),
  audioTokens: (json['audioTokens'] as num?)?.toInt(),
  acceptedPredictionTokens: (json['acceptedPredictionTokens'] as num?)?.toInt(),
  rejectedPredictionTokens: (json['rejectedPredictionTokens'] as num?)?.toInt(),
);

Map<String, dynamic> _$CompletionTokenDetailsToJson(
  CompletionTokenDetails instance,
) => <String, dynamic>{
  'reasoningTokens': instance.reasoningTokens,
  'audioTokens': instance.audioTokens,
  'acceptedPredictionTokens': instance.acceptedPredictionTokens,
  'rejectedPredictionTokens': instance.rejectedPredictionTokens,
};

Custom _$CustomFromJson(Map<String, dynamic> json) =>
    Custom(input: json['input'] as String, name: json['name'] as String);

Map<String, dynamic> _$CustomToJson(Custom instance) => <String, dynamic>{
  'input': instance.input,
  'name': instance.name,
};
