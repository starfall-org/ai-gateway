import 'package:json_annotation/json_annotation.dart';

import '../../llm_model/basic_model.dart';

part 'models.g.dart';

@JsonSerializable()
class AnthropicModels {
  final List<BasicModel> data;
  @JsonKey(name: 'first_id')
  final String firstId;
  @JsonKey(name: 'has_more')
  final bool hasMore;
  @JsonKey(name: 'last_id')
  final String lastId;

  AnthropicModels({
    required this.data,
    required this.firstId,
    required this.hasMore,
    required this.lastId,
  });

  factory AnthropicModels.fromJson(Map<String, dynamic> json) =>
      _$AnthropicModelsFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicModelsToJson(this);
}
