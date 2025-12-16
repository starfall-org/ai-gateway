import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/theme.dart';
import 'base_repository.dart';

class ThemeRepository extends BaseRepository<ThemeSettings> {
  static const String _boxName = 'theme_settings';

  // Expose a notifier for valid reactive UI updates
  final ValueNotifier<ThemeSettings> themeNotifier = ValueNotifier(
    ThemeSettings.defaults(),
  );

  ThemeRepository(super.box) {
    _loadInitialTheme();
  }

  void _loadInitialTheme() {
    final items = getItems();
    if (items.isNotEmpty) {
      themeNotifier.value = items.first;
    }
  }

  static Future<ThemeRepository> init() async {
    final box = await Hive.openBox<String>(_boxName);
    return ThemeRepository(box);
  }

  @override
  String get boxName => _boxName;

  @override
  ThemeSettings deserializeItem(String json) =>
      ThemeSettings.fromJsonString(json);

  @override
  String serializeItem(ThemeSettings item) => item.toJsonString();

  // Single settings object, so ID is constant
  @override
  String getItemId(ThemeSettings item) => 'settings';

  Future<void> updateSettings(ThemeSettings settings) async {
    // We only ever store one item for settings
    await saveItem(settings);
    themeNotifier.value = settings;
  }

  ThemeSettings get currentTheme => themeNotifier.value;
}
