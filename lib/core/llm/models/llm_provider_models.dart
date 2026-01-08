import 'package:json_annotation/json_annotation.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';

part 'llm_provider_models.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LlmProviderModels {
  final String id;
  List<LlmModel?> models;

  LlmProviderModels({required this.id, required this.models});

  factory LlmProviderModels.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderModelsFromJson(json);

  Map<String, dynamic> toJson() => _$LlmProviderModelsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LlmModel {
  final String id;
  final String? icon;
  final String displayName;
  final LlmModelType type;
  final dynamic
  origin; // ACCEPT: BasicModel, GitHubModel, GoogleAiModel, OllamaModel

  LlmModel({
    required this.id,
    this.icon,
    required this.displayName,
    required this.type,
    required this.origin,
  }) : assert(
         origin is BasicModel ||
             origin is GitHubModel ||
             origin is GoogleAiModel ||
             origin is OllamaModel,
       );

  factory LlmModel.fromJson(Map<String, dynamic> json) =>
      _$LlmModelFromJson(json);

  Map<String, dynamic> toJson() => _$LlmModelToJson(this);
}

enum LlmModelType { chat, image, audio, video, embed }
