// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeminiGenerateContentRequest _$GeminiGenerateContentRequestFromJson(
  Map<String, dynamic> json,
) => GeminiGenerateContentRequest(
  contents: (json['contents'] as List<dynamic>)
      .map((e) => GeminiContent.fromJson(e as Map<String, dynamic>))
      .toList(),
  generationConfig: json['generationConfig'] == null
      ? null
      : GeminiGenerationConfig.fromJson(
          json['generationConfig'] as Map<String, dynamic>,
        ),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => GeminiTool.fromJson(e as Map<String, dynamic>))
      .toList(),
  toolConfig: json['toolConfig'] == null
      ? null
      : GeminiToolConfig.fromJson(json['toolConfig'] as Map<String, dynamic>),
  safetySettings: (json['safetySettings'] as List<dynamic>?)
      ?.map((e) => GeminiSafetySetting.fromJson(e as Map<String, dynamic>))
      .toList(),
  systemInstruction: json['systemInstruction'],
);

Map<String, dynamic> _$GeminiGenerateContentRequestToJson(
  GeminiGenerateContentRequest instance,
) => <String, dynamic>{
  'contents': instance.contents,
  'generationConfig': instance.generationConfig,
  'tools': instance.tools,
  'toolConfig': instance.toolConfig,
  'safetySettings': instance.safetySettings,
  'systemInstruction': instance.systemInstruction,
};

GeminiContent _$GeminiContentFromJson(Map<String, dynamic> json) =>
    GeminiContent(
      parts: (json['parts'] as List<dynamic>?)
          ?.map((e) => GeminiPart.fromJson(e as Map<String, dynamic>))
          .toList(),
      role: json['role'] as String?,
    );

Map<String, dynamic> _$GeminiContentToJson(GeminiContent instance) =>
    <String, dynamic>{'parts': instance.parts, 'role': instance.role};

GeminiPart _$GeminiPartFromJson(Map<String, dynamic> json) => GeminiPart(
  text: json['text'] as String?,
  inlineData: json['inlineData'] == null
      ? null
      : GeminiInlineData.fromJson(json['inlineData'] as Map<String, dynamic>),
  fileData: json['fileData'] == null
      ? null
      : GeminiFileData.fromJson(json['fileData'] as Map<String, dynamic>),
  functionCall: json['functionCall'] == null
      ? null
      : GeminiFunctionCall.fromJson(
          json['functionCall'] as Map<String, dynamic>,
        ),
  functionResponse: json['functionResponse'] == null
      ? null
      : GeminiFunctionResponse.fromJson(
          json['functionResponse'] as Map<String, dynamic>,
        ),
  executableCode: json['executableCode'] == null
      ? null
      : GeminiExecutableCode.fromJson(
          json['executableCode'] as Map<String, dynamic>,
        ),
  codeExecutionResult: json['codeExecutionResult'] == null
      ? null
      : GeminiCodeExecutionResult.fromJson(
          json['codeExecutionResult'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GeminiPartToJson(GeminiPart instance) =>
    <String, dynamic>{
      'text': instance.text,
      'inlineData': instance.inlineData,
      'fileData': instance.fileData,
      'functionCall': instance.functionCall,
      'functionResponse': instance.functionResponse,
      'executableCode': instance.executableCode,
      'codeExecutionResult': instance.codeExecutionResult,
    };

GeminiInlineData _$GeminiInlineDataFromJson(Map<String, dynamic> json) =>
    GeminiInlineData(
      mimeType: json['mimeType'] as String?,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$GeminiInlineDataToJson(GeminiInlineData instance) =>
    <String, dynamic>{'mimeType': instance.mimeType, 'data': instance.data};

GeminiFileData _$GeminiFileDataFromJson(Map<String, dynamic> json) =>
    GeminiFileData(
      mimeType: json['mimeType'] as String?,
      fileUri: json['fileUri'] as String?,
    );

Map<String, dynamic> _$GeminiFileDataToJson(GeminiFileData instance) =>
    <String, dynamic>{
      'mimeType': instance.mimeType,
      'fileUri': instance.fileUri,
    };

GeminiFunctionCall _$GeminiFunctionCallFromJson(Map<String, dynamic> json) =>
    GeminiFunctionCall(
      name: json['name'] as String?,
      args: json['args'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GeminiFunctionCallToJson(GeminiFunctionCall instance) =>
    <String, dynamic>{'name': instance.name, 'args': instance.args};

GeminiFunctionResponse _$GeminiFunctionResponseFromJson(
  Map<String, dynamic> json,
) => GeminiFunctionResponse(
  name: json['name'] as String?,
  response: json['response'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$GeminiFunctionResponseToJson(
  GeminiFunctionResponse instance,
) => <String, dynamic>{'name': instance.name, 'response': instance.response};

GeminiExecutableCode _$GeminiExecutableCodeFromJson(
  Map<String, dynamic> json,
) => GeminiExecutableCode(
  language: json['language'] as String?,
  code: json['code'] as String?,
);

Map<String, dynamic> _$GeminiExecutableCodeToJson(
  GeminiExecutableCode instance,
) => <String, dynamic>{'language': instance.language, 'code': instance.code};

GeminiCodeExecutionResult _$GeminiCodeExecutionResultFromJson(
  Map<String, dynamic> json,
) => GeminiCodeExecutionResult(
  outcome: json['outcome'] as String?,
  output: json['output'] as String?,
);

Map<String, dynamic> _$GeminiCodeExecutionResultToJson(
  GeminiCodeExecutionResult instance,
) => <String, dynamic>{'outcome': instance.outcome, 'output': instance.output};

GeminiGenerationConfig _$GeminiGenerationConfigFromJson(
  Map<String, dynamic> json,
) => GeminiGenerationConfig(
  temperature: (json['temperature'] as num?)?.toDouble(),
  maxOutputTokens: (json['maxOutputTokens'] as num?)?.toInt(),
  topP: (json['topP'] as num?)?.toDouble(),
  topK: (json['topK'] as num?)?.toInt(),
  stopSequences: (json['stopSequences'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  responseMimeType: json['responseMimeType'] as String?,
  responseSchema: json['responseSchema'] as Map<String, dynamic>?,
  candidateCount: (json['candidateCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$GeminiGenerationConfigToJson(
  GeminiGenerationConfig instance,
) => <String, dynamic>{
  'temperature': instance.temperature,
  'maxOutputTokens': instance.maxOutputTokens,
  'topP': instance.topP,
  'topK': instance.topK,
  'stopSequences': instance.stopSequences,
  'responseMimeType': instance.responseMimeType,
  'responseSchema': instance.responseSchema,
  'candidateCount': instance.candidateCount,
};

GeminiTool _$GeminiToolFromJson(Map<String, dynamic> json) => GeminiTool(
  functionDeclarations: (json['functionDeclarations'] as List<dynamic>?)
      ?.map(
        (e) => GeminiFunctionDeclaration.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  codeExecution: json['codeExecution'] == null
      ? null
      : GeminiCodeExecution.fromJson(
          json['codeExecution'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GeminiToolToJson(GeminiTool instance) =>
    <String, dynamic>{
      'functionDeclarations': instance.functionDeclarations,
      'codeExecution': instance.codeExecution,
    };

GeminiFunctionDeclaration _$GeminiFunctionDeclarationFromJson(
  Map<String, dynamic> json,
) => GeminiFunctionDeclaration(
  name: json['name'] as String?,
  description: json['description'] as String?,
  parameters: json['parameters'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$GeminiFunctionDeclarationToJson(
  GeminiFunctionDeclaration instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'parameters': instance.parameters,
};

GeminiCodeExecution _$GeminiCodeExecutionFromJson(Map<String, dynamic> json) =>
    GeminiCodeExecution();

Map<String, dynamic> _$GeminiCodeExecutionToJson(
  GeminiCodeExecution instance,
) => <String, dynamic>{};

GeminiToolConfig _$GeminiToolConfigFromJson(Map<String, dynamic> json) =>
    GeminiToolConfig(
      functionCallingConfig: json['functionCallingConfig'] == null
          ? null
          : GeminiFunctionCallingConfig.fromJson(
              json['functionCallingConfig'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$GeminiToolConfigToJson(GeminiToolConfig instance) =>
    <String, dynamic>{'functionCallingConfig': instance.functionCallingConfig};

GeminiFunctionCallingConfig _$GeminiFunctionCallingConfigFromJson(
  Map<String, dynamic> json,
) => GeminiFunctionCallingConfig(
  mode: json['mode'] as String?,
  allowedFunctionNames: (json['allowedFunctionNames'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GeminiFunctionCallingConfigToJson(
  GeminiFunctionCallingConfig instance,
) => <String, dynamic>{
  'mode': instance.mode,
  'allowedFunctionNames': instance.allowedFunctionNames,
};

GeminiSafetySetting _$GeminiSafetySettingFromJson(Map<String, dynamic> json) =>
    GeminiSafetySetting(
      category: json['category'] as String?,
      threshold: json['threshold'] as String?,
    );

Map<String, dynamic> _$GeminiSafetySettingToJson(
  GeminiSafetySetting instance,
) => <String, dynamic>{
  'category': instance.category,
  'threshold': instance.threshold,
};

GeminiGenerateContentResponse _$GeminiGenerateContentResponseFromJson(
  Map<String, dynamic> json,
) => GeminiGenerateContentResponse(
  candidates: (json['candidates'] as List<dynamic>?)
      ?.map((e) => GeminiCandidate.fromJson(e as Map<String, dynamic>))
      .toList(),
  usageMetadata: json['usageMetadata'] == null
      ? null
      : GeminiUsageMetadata.fromJson(
          json['usageMetadata'] as Map<String, dynamic>,
        ),
  promptFeedback: json['promptFeedback'] == null
      ? null
      : GeminiPromptFeedback.fromJson(
          json['promptFeedback'] as Map<String, dynamic>,
        ),
  modelVersion: json['modelVersion'] as String?,
);

Map<String, dynamic> _$GeminiGenerateContentResponseToJson(
  GeminiGenerateContentResponse instance,
) => <String, dynamic>{
  'candidates': instance.candidates,
  'usageMetadata': instance.usageMetadata,
  'promptFeedback': instance.promptFeedback,
  'modelVersion': instance.modelVersion,
};

GeminiCandidate _$GeminiCandidateFromJson(Map<String, dynamic> json) =>
    GeminiCandidate(
      content: json['content'] == null
          ? null
          : GeminiContent.fromJson(json['content'] as Map<String, dynamic>),
      finishReason: json['finishReason'] as String?,
      avgLogprobs: (json['avgLogprobs'] as num?)?.toDouble(),
      index: (json['index'] as num?)?.toInt(),
      safetyRatings: (json['safetyRatings'] as List<dynamic>?)
          ?.map((e) => GeminiSafetyRating.fromJson(e as Map<String, dynamic>))
          .toList(),
      citationMetadata: json['citationMetadata'] == null
          ? null
          : GeminiCitationMetadata.fromJson(
              json['citationMetadata'] as Map<String, dynamic>,
            ),
      groundingMetadata: json['groundingMetadata'] == null
          ? null
          : GeminiGroundingMetadata.fromJson(
              json['groundingMetadata'] as Map<String, dynamic>,
            ),
      logprobsResult: json['logprobsResult'] == null
          ? null
          : GeminiLogprobsResult.fromJson(
              json['logprobsResult'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$GeminiCandidateToJson(GeminiCandidate instance) =>
    <String, dynamic>{
      'content': instance.content,
      'finishReason': instance.finishReason,
      'avgLogprobs': instance.avgLogprobs,
      'index': instance.index,
      'safetyRatings': instance.safetyRatings,
      'citationMetadata': instance.citationMetadata,
      'groundingMetadata': instance.groundingMetadata,
      'logprobsResult': instance.logprobsResult,
    };

GeminiSafetyRating _$GeminiSafetyRatingFromJson(Map<String, dynamic> json) =>
    GeminiSafetyRating(
      category: json['category'] as String?,
      probability: json['probability'] as String?,
      severity: json['severity'] as String?,
    );

Map<String, dynamic> _$GeminiSafetyRatingToJson(GeminiSafetyRating instance) =>
    <String, dynamic>{
      'category': instance.category,
      'probability': instance.probability,
      'severity': instance.severity,
    };

GeminiCitationMetadata _$GeminiCitationMetadataFromJson(
  Map<String, dynamic> json,
) => GeminiCitationMetadata(
  citationSources: (json['citationSources'] as List<dynamic>?)
      ?.map((e) => GeminiCitationSource.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GeminiCitationMetadataToJson(
  GeminiCitationMetadata instance,
) => <String, dynamic>{'citationSources': instance.citationSources};

GeminiCitationSource _$GeminiCitationSourceFromJson(
  Map<String, dynamic> json,
) => GeminiCitationSource(
  startIndex: (json['startIndex'] as num?)?.toInt(),
  endIndex: (json['endIndex'] as num?)?.toInt(),
  uri: json['uri'] as String?,
  license: json['license'] as String?,
);

Map<String, dynamic> _$GeminiCitationSourceToJson(
  GeminiCitationSource instance,
) => <String, dynamic>{
  'startIndex': instance.startIndex,
  'endIndex': instance.endIndex,
  'uri': instance.uri,
  'license': instance.license,
};

GeminiGroundingMetadata _$GeminiGroundingMetadataFromJson(
  Map<String, dynamic> json,
) => GeminiGroundingMetadata(
  groundingChunks: (json['groundingChunks'] as List<dynamic>?)
      ?.map((e) => GeminiGroundingChunk.fromJson(e as Map<String, dynamic>))
      .toList(),
  groundingPassages: (json['groundingPassages'] as List<dynamic>?)
      ?.map((e) => GeminiGroundingPassage.fromJson(e as Map<String, dynamic>))
      .toList(),
  searchEntryPoint: json['searchEntryPoint'] == null
      ? null
      : GeminiSearchEntryPoint.fromJson(
          json['searchEntryPoint'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GeminiGroundingMetadataToJson(
  GeminiGroundingMetadata instance,
) => <String, dynamic>{
  'groundingChunks': instance.groundingChunks,
  'groundingPassages': instance.groundingPassages,
  'searchEntryPoint': instance.searchEntryPoint,
};

GeminiGroundingChunk _$GeminiGroundingChunkFromJson(
  Map<String, dynamic> json,
) => GeminiGroundingChunk(
  web: json['web'] == null
      ? null
      : GeminiGroundingSegment.fromJson(json['web'] as Map<String, dynamic>),
  index: (json['index'] as num?)?.toInt(),
);

Map<String, dynamic> _$GeminiGroundingChunkToJson(
  GeminiGroundingChunk instance,
) => <String, dynamic>{'web': instance.web, 'index': instance.index};

GeminiGroundingSegment _$GeminiGroundingSegmentFromJson(
  Map<String, dynamic> json,
) => GeminiGroundingSegment(
  uri: json['uri'] as String?,
  startIndex: (json['startIndex'] as num?)?.toInt(),
  endIndex: (json['endIndex'] as num?)?.toInt(),
  title: json['title'] as String?,
);

Map<String, dynamic> _$GeminiGroundingSegmentToJson(
  GeminiGroundingSegment instance,
) => <String, dynamic>{
  'uri': instance.uri,
  'startIndex': instance.startIndex,
  'endIndex': instance.endIndex,
  'title': instance.title,
};

GeminiGroundingPassage _$GeminiGroundingPassageFromJson(
  Map<String, dynamic> json,
) => GeminiGroundingPassage(
  id: (json['id'] as num?)?.toInt(),
  passageText: json['passageText'] as String?,
  sources: (json['sources'] as List<dynamic>?)
      ?.map((e) => GeminiGroundingSegment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GeminiGroundingPassageToJson(
  GeminiGroundingPassage instance,
) => <String, dynamic>{
  'id': instance.id,
  'passageText': instance.passageText,
  'sources': instance.sources,
};

GeminiSearchEntryPoint _$GeminiSearchEntryPointFromJson(
  Map<String, dynamic> json,
) => GeminiSearchEntryPoint(
  renderedContent: json['renderedContent'] as String?,
  entries: (json['entries'] as List<dynamic>?)
      ?.map((e) => GeminiSearchEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GeminiSearchEntryPointToJson(
  GeminiSearchEntryPoint instance,
) => <String, dynamic>{
  'renderedContent': instance.renderedContent,
  'entries': instance.entries,
};

GeminiSearchEntry _$GeminiSearchEntryFromJson(Map<String, dynamic> json) =>
    GeminiSearchEntry(
      title: json['title'] as String?,
      uri: json['uri'] as String?,
    );

Map<String, dynamic> _$GeminiSearchEntryToJson(GeminiSearchEntry instance) =>
    <String, dynamic>{'title': instance.title, 'uri': instance.uri};

GeminiLogprobsResult _$GeminiLogprobsResultFromJson(
  Map<String, dynamic> json,
) => GeminiLogprobsResult(
  chosenCandidates: (json['chosenCandidates'] as List<dynamic>?)
      ?.map((e) => GeminiCandidateLogprobs.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GeminiLogprobsResultToJson(
  GeminiLogprobsResult instance,
) => <String, dynamic>{'chosenCandidates': instance.chosenCandidates};

GeminiCandidateLogprobs _$GeminiCandidateLogprobsFromJson(
  Map<String, dynamic> json,
) => GeminiCandidateLogprobs(
  candidates: (json['candidates'] as List<dynamic>?)
      ?.map((e) => GeminiLogprobsCandidates.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GeminiCandidateLogprobsToJson(
  GeminiCandidateLogprobs instance,
) => <String, dynamic>{'candidates': instance.candidates};

GeminiLogprobsCandidates _$GeminiLogprobsCandidatesFromJson(
  Map<String, dynamic> json,
) => GeminiLogprobsCandidates(
  topCandidates: (json['topCandidates'] as List<dynamic>?)
      ?.map((e) => GeminiTopCandidate.fromJson(e as Map<String, dynamic>))
      .toList(),
  tokenPosition: (json['tokenPosition'] as num?)?.toInt(),
);

Map<String, dynamic> _$GeminiLogprobsCandidatesToJson(
  GeminiLogprobsCandidates instance,
) => <String, dynamic>{
  'topCandidates': instance.topCandidates,
  'tokenPosition': instance.tokenPosition,
};

GeminiTopCandidate _$GeminiTopCandidateFromJson(Map<String, dynamic> json) =>
    GeminiTopCandidate(
      token: json['token'] as String?,
      logProbability: (json['logProbability'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$GeminiTopCandidateToJson(GeminiTopCandidate instance) =>
    <String, dynamic>{
      'token': instance.token,
      'logProbability': instance.logProbability,
    };

GeminiUsageMetadata _$GeminiUsageMetadataFromJson(Map<String, dynamic> json) =>
    GeminiUsageMetadata(
      promptTokenCount: (json['promptTokenCount'] as num?)?.toInt(),
      candidatesTokenCount: (json['candidatesTokenCount'] as num?)?.toInt(),
      totalTokenCount: (json['totalTokenCount'] as num?)?.toInt(),
      cachedContentTokenCount: json['cachedContentTokenCount'] == null
          ? null
          : GeminiCachedContentTokenCount.fromJson(
              json['cachedContentTokenCount'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$GeminiUsageMetadataToJson(
  GeminiUsageMetadata instance,
) => <String, dynamic>{
  'promptTokenCount': instance.promptTokenCount,
  'candidatesTokenCount': instance.candidatesTokenCount,
  'totalTokenCount': instance.totalTokenCount,
  'cachedContentTokenCount': instance.cachedContentTokenCount,
};

GeminiCachedContentTokenCount _$GeminiCachedContentTokenCountFromJson(
  Map<String, dynamic> json,
) => GeminiCachedContentTokenCount(
  totalTokens: (json['totalTokens'] as num?)?.toInt(),
);

Map<String, dynamic> _$GeminiCachedContentTokenCountToJson(
  GeminiCachedContentTokenCount instance,
) => <String, dynamic>{'totalTokens': instance.totalTokens};

GeminiPromptFeedback _$GeminiPromptFeedbackFromJson(
  Map<String, dynamic> json,
) => GeminiPromptFeedback(
  safetyRatings: (json['safetyRatings'] as List<dynamic>?)
      ?.map((e) => GeminiSafetyRating.fromJson(e as Map<String, dynamic>))
      .toList(),
  blockReason: json['blockReason'] as String?,
);

Map<String, dynamic> _$GeminiPromptFeedbackToJson(
  GeminiPromptFeedback instance,
) => <String, dynamic>{
  'safetyRatings': instance.safetyRatings,
  'blockReason': instance.blockReason,
};
