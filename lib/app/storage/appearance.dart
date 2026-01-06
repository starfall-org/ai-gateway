import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/appearance_setting.dart';
import 'shared_prefs_base.dart';

class AppearanceSp extends SharedPreferencesBase<AppearanceSetting> {
  static const String _prefix = 'appearance';

  // Expose a notifier for valid reactive UI updates
  final ValueNotifier<AppearanceSetting> themeNotifier = ValueNotifier(
    AppearanceSetting.defaults(themeMode: ThemeMode.system),
  );

  AppearanceSp(super.prefs) {
    _loadInitialTheme();
    // Auto-refresh notifier on any storage change (no restart needed)
    changes.listen((_) {
      final items = getItems();
      if (items.isNotEmpty) {
        themeNotifier.value = items.first;
      } else {
        themeNotifier.value = AppearanceSetting.defaults(themeMode: ThemeMode.system);
      }
    });
  }

  void _loadInitialTheme() {
    final items = getItems();
    if (items.isNotEmpty) {
      themeNotifier.value = items.first;
    }
  }

  static AppearanceSp? _instance;

  static Future<AppearanceSp> init() async {
    if (_instance != null) {
      return _instance!;
    }
    final prefs = await SharedPreferences.getInstance();
    _instance = AppearanceSp(prefs);
    return _instance!;
  }

  static AppearanceSp get instance {
    if (_instance == null) {
      throw Exception('AppearanceSp not initialized. Call init() first.');
    }
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  // Single settings object, so ID is constant
  @override
  String getItemId(AppearanceSetting item) => 'settings';

  @override
  Map<String, dynamic> serializeToFields(AppearanceSetting item) {
    return {
      'themeMode': item.themeMode.index,
      'selection': item.selection.index,
      'colors': item.colors.toJson(),
      'font': item.font.toJson(),
      'superDarkMode': item.superDarkMode,
      'dynamicColor': item.dynamicColor,
      'enableAnimation': item.enableAnimation,
    };
  }

  @override
  AppearanceSetting deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    final int? themeModeIndex = fields['themeMode'] as int?;
    final int? selectionIndex = fields['selection'] as int?;

    final ThemeMode mode =
        (themeModeIndex != null &&
            themeModeIndex >= 0 &&
            themeModeIndex < ThemeMode.values.length)
        ? ThemeMode.values[themeModeIndex]
        : ThemeMode.system;

    final ThemeSelection sel =
        (selectionIndex != null &&
            selectionIndex >= 0 &&
            selectionIndex < ThemeSelection.values.length)
        ? ThemeSelection.values[selectionIndex]
        : ThemeSelection.system;

    // Xác định màu mặc định dựa trên theme mode
    final bool isDark = mode == ThemeMode.dark;

    // Parse nested objects
    final colorsMap = fields['colors'] as Map<String, dynamic>?;
    final fontMap = fields['font'] as Map<String, dynamic>?;

    final colors = colorsMap != null
        ? ColorSettings.fromJson(colorsMap)
        : ColorSettings.defaults(isDark: isDark);

    final font = fontMap != null
        ? FontSettings.fromJson(fontMap)
        : FontSettings.defaults();

    return AppearanceSetting(
      themeMode: mode,
      selection: sel,
      colors: colors,
      font: font,
      superDarkMode: fields['superDarkMode'] as bool? ?? false,
      dynamicColor: fields['dynamicColor'] as bool? ?? false,
      enableAnimation: fields['enableAnimation'] as bool? ?? true,
    );
  }

  Future<void> updateSettings(AppearanceSetting settings) async {
    // We only ever store one item for settings
    await saveItem(settings);
    themeNotifier.value = settings;
  }

  AppearanceSetting get currentTheme => themeNotifier.value;
}
