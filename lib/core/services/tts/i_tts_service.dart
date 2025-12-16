import 'dart:typed_data';

abstract class ITTSService {
  Future<Uint8List> synthesize(
    String text,
    String model,
    String? voiceId,
    Map<String, dynamic> settings, {
    String? apiKey,
    String? baseApiUrl,
  });
}
