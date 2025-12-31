/// Base JSON-RPC 2.0 message structure
abstract class MCPMessage {
  final String jsonrpc = '2.0';

  Map<String, dynamic> toJson();
}

/// JSON-RPC 2.0 Request
class MCPRequest extends MCPMessage {
  final dynamic id;
  final String method;
  final Map<String, dynamic>? params;

  MCPRequest({
    required this.id,
    required this.method,
    this.params,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      'method': method,
      if (params != null) 'params': params,
    };
  }

  factory MCPRequest.fromJson(Map<String, dynamic> json) {
    return MCPRequest(
      id: json['id'],
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}

/// JSON-RPC 2.0 Notification
class MCPNotification extends MCPMessage {
  final String method;
  final Map<String, dynamic>? params;

  MCPNotification({
    required this.method,
    this.params,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'method': method,
      if (params != null) 'params': params,
    };
  }

  factory MCPNotification.fromJson(Map<String, dynamic> json) {
    return MCPNotification(
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}

/// JSON-RPC 2.0 Response
class MCPResponse extends MCPMessage {
  final dynamic id;
  final dynamic result;
  final MCPError? error;

  MCPResponse({
    required this.id,
    this.result,
    this.error,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      if (result != null) 'result': result,
      if (error != null) 'error': error!.toJson(),
    };
  }

  factory MCPResponse.fromJson(Map<String, dynamic> json) {
    return MCPResponse(
      id: json['id'],
      result: json['result'],
      error: json['error'] != null
          ? MCPError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// JSON-RPC 2.0 Error
class MCPError {
  final int code;
  final String message;
  final dynamic data;

  MCPError({
    required this.code,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (data != null) 'data': data,
    };
  }

  factory MCPError.fromJson(Map<String, dynamic> json) {
    return MCPError(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }
}
