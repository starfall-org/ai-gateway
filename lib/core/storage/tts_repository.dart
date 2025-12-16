import 'package:hive_flutter/hive_flutter.dart';
import '../models/tts_profile.dart';
import 'base_repository.dart';

class TTSRepository extends BaseRepository<TTSProfile> {
  static const String _boxName = 'tts_profiles';

  TTSRepository(super.box);

  static Future<TTSRepository> init() async {
    final box = await Hive.openBox<String>(_boxName);
    return TTSRepository(box);
  }

  @override
  String get boxName => _boxName;

  @override
  TTSProfile deserializeItem(String json) => TTSProfile.fromJsonString(json);

  @override
  String serializeItem(TTSProfile item) => item.toJsonString();

  @override
  String getItemId(TTSProfile item) => item.id;

  List<TTSProfile> getProfiles() => getItems();

  Future<void> addProfile(TTSProfile profile) => saveItem(profile);

  Future<void> deleteProfile(String id) => deleteItem(id);
}
