import 'package:json_annotation/json_annotation.dart';

part 'llm_provider_config.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LlmProviderConfig {
  final String providerId;
  @JsonKey(name: 'http_proxy')
  final Map<String, dynamic> httpProxy;
  @JsonKey(name: 'custom_chat_completion_url')
  final String? customChatCompletionUrl;
  @JsonKey(name: 'custom_list_models_url')
  final String? customListModelsUrl;

  LlmProviderConfig({
    required this.providerId,
    required this.httpProxy,
    this.customChatCompletionUrl,
    this.customListModelsUrl,
  });

  factory LlmProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LlmProviderConfigToJson(this);
}
