class OllamaChatResponse {
  final Map<String, dynamic> raw;
  OllamaChatResponse(this.raw);

  String get outputText {
    try {
      final msg = raw['message'];
      if (msg is Map) {
        final c = msg['content'];
        if (c is String) return c;
      }
      final resp = raw['response'];
      if (resp is String) return resp;
    } catch (_) {}
    return '';
  }

  factory OllamaChatResponse.fromJson(Map<String, dynamic> json) {
    return OllamaChatResponse(json);
  }
}

class OllamaGenerateResponse {
  final Map<String, dynamic> raw;
  OllamaGenerateResponse(this.raw);

  String get outputText {
    try {
      final resp = raw['response'];
      if (resp is String) return resp;
    } catch (_) {}
    return '';
  }

  factory OllamaGenerateResponse.fromJson(Map<String, dynamic> json) {
    return OllamaGenerateResponse(json);
  }
}

class OllamaEmbeddingsResponse {
  final Map<String, dynamic> raw;
  OllamaEmbeddingsResponse(this.raw);

  List<double>? get embedding {
    try {
      final emb = raw['embedding'];
      if (emb is List) {
        return emb
            .map((e) => e is num ? e.toDouble() : double.parse(e.toString()))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  factory OllamaEmbeddingsResponse.fromJson(Map<String, dynamic> json) {
    return OllamaEmbeddingsResponse(json);
  }
}