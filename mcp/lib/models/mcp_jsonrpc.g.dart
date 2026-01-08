// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_jsonrpc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MCPRequest _$MCPRequestFromJson(Map<String, dynamic> json) => MCPRequest(
  id: json['id'],
  method: json['method'] as String,
  params: json['params'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MCPRequestToJson(MCPRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'method': instance.method,
      'params': instance.params,
    };

MCPNotification _$MCPNotificationFromJson(Map<String, dynamic> json) =>
    MCPNotification(
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MCPNotificationToJson(MCPNotification instance) =>
    <String, dynamic>{'method': instance.method, 'params': instance.params};

MCPResponse _$MCPResponseFromJson(Map<String, dynamic> json) => MCPResponse(
  id: json['id'],
  result: json['result'],
  error: json['error'] == null
      ? null
      : MCPError.fromJson(json['error'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MCPResponseToJson(MCPResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'result': instance.result,
      'error': instance.error?.toJson(),
    };

MCPError _$MCPErrorFromJson(Map<String, dynamic> json) => MCPError(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$MCPErrorToJson(MCPError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};
