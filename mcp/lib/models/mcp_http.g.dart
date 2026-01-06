// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_http.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MCPHttpConfig _$MCPHttpConfigFromJson(Map<String, dynamic> json) =>
    MCPHttpConfig(
      url: json['url'] as String,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$MCPHttpConfigToJson(MCPHttpConfig instance) =>
    <String, dynamic>{'url': instance.url, 'headers': instance.headers};
