class GoogleGenerateContentResponse {
  final Map<String, dynamic> raw;
  GoogleGenerateContentResponse(this.raw);

  String get outputText {
    try {
      final cands = raw['candidates'];
      if (cands is List && cands.isNotEmpty) {
        final first = cands.first;
        if (first is Map) {
          final content = first['content'];
          if (content is Map) {
            final parts = content['parts'];
            if (parts is List && parts.isNotEmpty) {
              final buf = StringBuffer();
              for (final p in parts) {
                if (p is Map && p['text'] is String) {
                  buf.write(p['text']);
                }
              }
              return buf.toString();
            }
          }
          // Fallback older shape
          final contentList = first['content'];
          if (contentList is List && contentList.isNotEmpty) {
            final p0 = contentList.first;
            if (p0 is Map && p0['text'] is String) {
              return p0['text'] as String;
            }
          }
        }
      }
    } catch (_) {}
    return '';
  }

  factory GoogleGenerateContentResponse.fromJson(Map<String, dynamic> json) {
    return GoogleGenerateContentResponse(json);
  }
}

class GoogleEmbedContentResponse {
  final Map<String, dynamic> raw;
  GoogleEmbedContentResponse(this.raw);

  /// Returns the first embedding vector if present.
  List<double>? get embedding {
    try {
      // Newer: { embedding: { values: [..] } }
      final emb = raw['embedding'];
      if (emb is Map) {
        final values = emb['values'] ?? emb['value'];
        if (values is List) {
          return values
              .map((e) => e is num ? e.toDouble() : double.parse(e.toString()))
              .toList();
        }
      }
      // Some variants: { embeddings: [{ values: [...] }] }
      final embs = raw['embeddings'];
      if (embs is List && embs.isNotEmpty && embs.first is Map) {
        final values = (embs.first as Map)['values'];
        if (values is List) {
          return values
              .map((e) => e is num ? e.toDouble() : double.parse(e.toString()))
              .toList();
        }
      }
    } catch (_) {}
    return null;
  }

  factory GoogleEmbedContentResponse.fromJson(Map<String, dynamic> json) {
    return GoogleEmbedContentResponse(json);
  }
}