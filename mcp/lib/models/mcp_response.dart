import 'mcp_core.dart';

/// Response result for 'initialize' method
class InitializeResult {
  final String protocolVersion;
  final MCPServerCapabilities capabilities;
  final MCPImplementation serverInfo;

  InitializeResult({
    required this.protocolVersion,
    required this.capabilities,
    required this.serverInfo,
  });

  factory InitializeResult.fromJson(Map<String, dynamic> json) {
    return InitializeResult(
      protocolVersion: json['protocolVersion'] as String,
      capabilities: MCPServerCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>,
      ),
      serverInfo: MCPImplementation.fromJson(
        json['serverInfo'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Response result for 'tools/list' method
class ListToolsResult {
  final List<MCPTool> tools;
  final String? nextCursor;

  ListToolsResult({required this.tools, this.nextCursor});

  factory ListToolsResult.fromJson(Map<String, dynamic> json) {
    return ListToolsResult(
      tools: (json['tools'] as List)
          .map((t) => MCPTool.fromJson(t as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Response result for 'tools/call' method
class CallToolResult {
  final List<MCPContent> content;
  final bool isError;

  CallToolResult({required this.content, this.isError = false});

  factory CallToolResult.fromJson(Map<String, dynamic> json) {
    return CallToolResult(
      content: (json['content'] as List)
          .map((c) => MCPContent.fromJson(c as Map<String, dynamic>))
          .toList(),
      isError: json['isError'] as bool? ?? false,
    );
  }
}

/// Response result for 'resources/list' method
class ListResourcesResult {
  final List<MCPResource> resources;
  final String? nextCursor;

  ListResourcesResult({required this.resources, this.nextCursor});

  factory ListResourcesResult.fromJson(Map<String, dynamic> json) {
    return ListResourcesResult(
      resources: (json['resources'] as List)
          .map((r) => MCPResource.fromJson(r as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Response result for 'resources/read' method
class ReadResourceResult {
  final List<MCPResourceContent> contents;

  ReadResourceResult({required this.contents});

  factory ReadResourceResult.fromJson(Map<String, dynamic> json) {
    return ReadResourceResult(
      contents: (json['contents'] as List)
          .map((c) => MCPResourceContent.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Response result for 'prompts/list' method
class ListPromptsResult {
  final List<MCPPrompt> prompts;
  final String? nextCursor;

  ListPromptsResult({required this.prompts, this.nextCursor});

  factory ListPromptsResult.fromJson(Map<String, dynamic> json) {
    return ListPromptsResult(
      prompts: (json['prompts'] as List)
          .map((p) => MCPPrompt.fromJson(p as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Response result for 'prompts/get' method
class GetPromptResult {
  final String? description;
  final List<MCPPromptMessage> messages;

  GetPromptResult({this.description, required this.messages});

  factory GetPromptResult.fromJson(Map<String, dynamic> json) {
    return GetPromptResult(
      description: json['description'] as String?,
      messages: (json['messages'] as List)
          .map((m) => MCPPromptMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
