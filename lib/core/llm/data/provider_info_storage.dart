import 'package:llm/llm.dart';
import 'package:metalore/core/storage/base.dart';

class ProviderInfoStorage extends HiveBaseStorage<ProviderInfo> {
  static const String _prefix = 'provider_info';

  ProviderInfoStorage();

  static Future<ProviderInfoStorage> init() async {
    return ProviderInfoStorage();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(ProviderInfo item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(ProviderInfo item) {
    return item.toJson();
  }

  @override
  ProviderInfo deserializeFromFields(String id, Map<String, dynamic> fields) {
    return ProviderInfo.fromJson(fields);
  }
}
