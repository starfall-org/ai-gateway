import 'package:hive_flutter/hive_flutter.dart';

import '../models/provider.dart';
import 'base_repository.dart';

class ProviderRepository extends BaseRepository<Provider> {
  static const String _boxName = 'providers';

  ProviderRepository(super.box);

  static Future<ProviderRepository> init() async {
    final box = await Hive.openBox<String>(_boxName);
    return ProviderRepository(box);
  }

  @override
  String get boxName => _boxName;

  @override
  Provider deserializeItem(String json) => Provider.fromJsonString(json);

  @override
  String serializeItem(Provider item) => item.toJsonString();

  @override
  String getItemId(Provider item) => item.name;

  List<Provider> getProviders() => getItems();

  Future<void> addProvider(Provider provider) => saveItem(provider);

  Future<void> updateProvider(Provider provider) => saveItem(provider);

  Future<void> deleteProvider(String name) => deleteItem(name);
}
