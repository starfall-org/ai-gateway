import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'speech_service.g.dart';

enum ServiceType { system, provider }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class SpeechService {
  final String id;
  final String name;
  final String? icon;

  final TextToSpeech tts;
  final SpeechToText stt;

  const SpeechService({
    required this.id,
    required this.name,
    this.icon,
    required this.tts,
    required this.stt,
  });

  Map<String, dynamic> toJson() {
    return _$SpeechServiceToJson(this);
  }

  factory SpeechService.fromJson(Map<String, dynamic> json) {
    return _$SpeechServiceFromJson(json);
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TextToSpeech {
  final ServiceType type;
  final String? provider;
  final String? modelId;
  final String? voiceId;
  final Map<String, dynamic> settings;

  const TextToSpeech({
    required this.type,
    this.provider,
    this.modelId,
    this.voiceId,
    this.settings = const <String, dynamic>{},
  });

  Map<String, dynamic> toJson() {
    final jsonMap = _$TextToSpeechToJson(this);
    jsonMap['settings'] = _normalizeSettingsMap(settings);
    return jsonMap;
  }

  factory TextToSpeech.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['settings'] = _normalizeSettingsMap(json['settings']);
    return _$TextToSpeechFromJson(normalized);
  }

  String toJsonString() => json.encode(toJson());

  factory TextToSpeech.fromJsonString(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw FormatException("Empty JSON string");
    }
    return TextToSpeech.fromJson(json.decode(jsonString));
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class SpeechToText {
  final ServiceType type;
  final String? provider;
  final String? modelId;
  final Map<String, dynamic> settings;

  const SpeechToText({
    required this.type,
    this.provider,
    this.modelId,
    this.settings = const <String, dynamic>{},
  });

  Map<String, dynamic> toJson() {
    final jsonMap = _$SpeechToTextToJson(this);
    jsonMap['settings'] = _normalizeSettingsMap(settings);
    return jsonMap;
  }

  factory SpeechToText.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['settings'] = _normalizeSettingsMap(json['settings']);
    return _$SpeechToTextFromJson(normalized);
  }
}

Map<String, dynamic> _normalizeSettingsMap(dynamic raw) {
  if (raw == null) return const <String, dynamic>{};

  if (raw is Map<String, dynamic>) {
    // Defensive copy to avoid unintended mutation across instances
    return Map<String, dynamic>.from(raw);
  }

  if (raw is Map) {
    final normalized = <String, dynamic>{};
    raw.forEach((key, value) {
      if (key is String) {
        normalized[key] = value;
      } else if (key != null) {
        normalized[key.toString()] = value;
      }
    });
    return normalized;
  }

  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        return _normalizeSettingsMap(decoded);
      }
    } catch (_) {
      // ignore malformed JSON; caller will receive empty map
    }
  }

  return const <String, dynamic>{};
}
