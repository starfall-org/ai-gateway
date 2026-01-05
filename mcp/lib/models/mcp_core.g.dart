// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_core.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonSchema _$JsonSchemaFromJson(Map<String, dynamic> json) => JsonSchema(
  type: json['type'] as String? ?? 'object',
  properties: JsonSchema._propertiesFromJson(json['properties']),
  required: (json['required'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  description: json['description'] as String?,
  additionalProperties: json['additional_properties'],
);

Map<String, dynamic> _$JsonSchemaToJson(JsonSchema instance) =>
    <String, dynamic>{
      'type': instance.type,
      'properties': JsonSchema._propertiesToJson(instance.properties),
      'required': instance.required,
      'description': instance.description,
      'additional_properties': instance.additionalProperties,
    };

JsonSchemaProperty _$JsonSchemaPropertyFromJson(Map<String, dynamic> json) =>
    JsonSchemaProperty(
      type: json['type'] as String,
      description: json['description'] as String?,
      enumValues: (json['enum'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      defaultValue: json['default'],
      items: json['items'] == null
          ? null
          : JsonSchema.fromJson(json['items'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JsonSchemaPropertyToJson(JsonSchemaProperty instance) =>
    <String, dynamic>{
      'type': instance.type,
      'description': instance.description,
      'enum': instance.enumValues,
      'default': instance.defaultValue,
      'items': instance.items?.toJson(),
    };

MCPTool _$MCPToolFromJson(Map<String, dynamic> json) => MCPTool(
  name: json['name'] as String,
  description: json['description'] as String?,
  inputSchema: JsonSchema.fromJson(
    json['input_schema'] as Map<String, dynamic>,
  ),
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$MCPToolToJson(MCPTool instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'input_schema': instance.inputSchema.toJson(),
  'enabled': instance.enabled,
};

MCPResource _$MCPResourceFromJson(Map<String, dynamic> json) => MCPResource(
  uri: json['uri'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  mimeType: json['mime_type'] as String?,
);

Map<String, dynamic> _$MCPResourceToJson(MCPResource instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'name': instance.name,
      'description': instance.description,
      'mime_type': instance.mimeType,
    };

MCPPromptArgument _$MCPPromptArgumentFromJson(Map<String, dynamic> json) =>
    MCPPromptArgument(
      name: json['name'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
    );

Map<String, dynamic> _$MCPPromptArgumentToJson(MCPPromptArgument instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'required': instance.required,
    };

MCPPrompt _$MCPPromptFromJson(Map<String, dynamic> json) => MCPPrompt(
  name: json['name'] as String,
  description: json['description'] as String?,
  arguments: (json['arguments'] as List<dynamic>?)
      ?.map((e) => MCPPromptArgument.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MCPPromptToJson(MCPPrompt instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'arguments': instance.arguments?.map((e) => e.toJson()).toList(),
};

MCPServerCapabilities _$MCPServerCapabilitiesFromJson(
  Map<String, dynamic> json,
) => MCPServerCapabilities(
  tools: json['tools'] as bool? ?? false,
  resources: json['resources'] as bool? ?? false,
  prompts: json['prompts'] as bool? ?? false,
  logging: json['logging'] as bool? ?? false,
);

Map<String, dynamic> _$MCPServerCapabilitiesToJson(
  MCPServerCapabilities instance,
) => <String, dynamic>{
  'tools': instance.tools,
  'resources': instance.resources,
  'prompts': instance.prompts,
  'logging': instance.logging,
};

MCPImplementation _$MCPImplementationFromJson(Map<String, dynamic> json) =>
    MCPImplementation(
      name: json['name'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$MCPImplementationToJson(MCPImplementation instance) =>
    <String, dynamic>{'name': instance.name, 'version': instance.version};

MCPTextContent _$MCPTextContentFromJson(Map<String, dynamic> json) =>
    MCPTextContent(json['text'] as String);

Map<String, dynamic> _$MCPTextContentToJson(MCPTextContent instance) =>
    <String, dynamic>{'text': instance.text};

MCPImageContent _$MCPImageContentFromJson(Map<String, dynamic> json) =>
    MCPImageContent(
      data: json['data'] as String,
      mimeType: json['mime_type'] as String,
    );

Map<String, dynamic> _$MCPImageContentToJson(MCPImageContent instance) =>
    <String, dynamic>{'data': instance.data, 'mime_type': instance.mimeType};

MCPResourceContent _$MCPResourceContentFromJson(Map<String, dynamic> json) =>
    MCPResourceContent(
      uri: json['uri'] as String,
      mimeType: json['mime_type'] as String?,
      text: json['text'] as String?,
      blob: json['blob'] as String?,
    );

Map<String, dynamic> _$MCPResourceContentToJson(MCPResourceContent instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'mime_type': instance.mimeType,
      'text': instance.text,
      'blob': instance.blob,
    };

MCPPromptMessage _$MCPPromptMessageFromJson(Map<String, dynamic> json) =>
    MCPPromptMessage(
      role: json['role'] as String,
      content: MCPPromptMessage._contentFromJson(
        json['content'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$MCPPromptMessageToJson(MCPPromptMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': MCPPromptMessage._contentToJson(instance.content),
    };
