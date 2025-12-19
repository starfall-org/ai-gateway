import 'package:flutter/material.dart';
import '../../../core/storage/theme_repository.dart';
import '../../../core/models/theme.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_card.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  final ThemeRepository _repository = ThemeRepository.instance;
  late ThemeSettings _settings;

  // 5 preset colors (must include black and white)
  static const List<Color> _presets = <Color>[
    Colors.black,
    Colors.white,
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _settings = _repository.currentTheme;
  }

  Future<void> _updateSelection(ThemeSelection selection) async {
    // Keep themeMode in sync for non-custom selections
    ThemeMode mode = _settings.themeMode;
    switch (selection) {
      case ThemeSelection.system:
        mode = ThemeMode.system;
        break;
      case ThemeSelection.light:
        mode = ThemeMode.light;
        break;
      case ThemeSelection.dark:
        mode = ThemeMode.dark;
        break;
      case ThemeSelection.custom:
        // keep current themeMode; custom only affects colors
        mode = _settings.themeMode;
        break;
    }
    final newSettings = _settings.copyWith(
      selection: selection,
      themeMode: mode,
    );
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _updatePrimary(int colorValue) async {
    final newSettings = _settings.copyWith(primaryColor: colorValue);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _updateSecondary(int colorValue) async {
    final newSettings = _settings.copyWith(secondaryColor: colorValue);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _togglePureDark(bool value) async {
    final newSettings = _settings.copyWith(pureDark: value);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _toggleMaterialYou(bool value) async {
    final newSettings = _settings.copyWith(materialYou: value);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _updateSecondaryBackgroundMode(
    SecondaryBackgroundMode mode,
  ) async {
    final newSettings = _settings.copyWith(secondaryBackgroundMode: mode);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _settings.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.appearance'.tr()),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme selection: system, light, dark, custom
          SettingsSectionHeader('settings.theme_mode'.tr()),
          const SizedBox(height: 12),
          _buildThemeSegmented(),

          // SuperDark Mode toggle - only visible when Dark mode is selected
          if (_settings.themeMode == ThemeMode.dark) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D0D0D),
                    Color(0xFF2D2D2D),
                    Color(0xFF888888), // Refraction streak
                    Color(0xFF2D2D2D),
                    Color(0xFF0D0D0D),
                  ],
                  stops: [0.0, 0.44, 0.5, 0.56, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: -4,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.15),
                    blurRadius: 0,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SettingsCard(
                backgroundColor: Colors.transparent,
                child: SwitchListTile(
                  title: Text(
                    'settings.pure_dark'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    'settings.pure_dark_desc'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  value: _settings.pureDark,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.3),
                  onChanged: (val) => _togglePureDark(val),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Material You toggle
          SettingsSectionHeader('settings.material_you'.tr()),
          DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              final bool supported =
                  (lightDynamic != null || darkDynamic != null);
              return SettingsCard(
                child: SwitchListTile(
                  title: Text('settings.material_you'.tr()),
                  subtitle: Text(
                    supported
                        ? 'settings.material_you_desc'.tr()
                        : 'settings.material_you_unsupported'.tr(),
                  ),
                  value: _settings.materialYou,
                  onChanged: supported
                      ? (val) => _toggleMaterialYou(val)
                      : null,
                ),
              );
            },
          ),

          // Secondary Background Mode (only when Material You is OFF)
          if (!_settings.materialYou) ...[
            const SizedBox(height: 12),
            SettingsSectionHeader('settings.secondary_background'.tr()),
            const SizedBox(height: 12),
            _buildSecondaryBgSegmented(),
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 12),
              child: Text(
                'settings.secondary_bg_border_rule'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Color customization is only visible in Custom mode and disabled when Material You is enabled
          if (!_settings.materialYou &&
              _settings.selection == ThemeSelection.custom) ...[
            SettingsSectionHeader('settings.primary_color'.tr()),
            const SizedBox(height: 8),
            _buildColorSelector(
              current: Color(_settings.primaryColor),
              onSelect: (c) => _updatePrimary(c.value),
            ),

            const SizedBox(height: 16),

            SettingsSectionHeader('settings.secondary_color'.tr()),
            const SizedBox(height: 8),
            _buildColorSelector(
              current: Color(_settings.secondaryColor),
              onSelect: (c) => _updateSecondary(c.value),
            ),
            const SizedBox(height: 24),
          ],

          _buildPreview(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildThemeSegmented() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeSelection>(
        segments: [
          ButtonSegment(
            value: ThemeSelection.system,
            label: const Icon(Icons.brightness_auto_outlined),
            tooltip: 'settings.system_default'.tr(),
          ),
          ButtonSegment(
            value: ThemeSelection.light,
            label: const Icon(Icons.light_mode_outlined),
            tooltip: 'settings.light'.tr(),
          ),
          ButtonSegment(
            value: ThemeSelection.dark,
            label: const Icon(Icons.dark_mode_outlined),
            tooltip: 'settings.dark'.tr(),
          ),
          ButtonSegment(
            value: ThemeSelection.custom,
            label: const Icon(Icons.palette_outlined),
            tooltip: 'settings.custom'.tr(),
          ),
        ],
        selected: {_settings.selection},
        onSelectionChanged: (Set<ThemeSelection> newSelection) {
          _updateSelection(newSelection.first);
        },
        showSelectedIcon: false,
      ),
    );
  }

  Widget _buildSecondaryBgSegmented() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<SecondaryBackgroundMode>(
        segments: [
          ButtonSegment(
            value: SecondaryBackgroundMode.on,
            label: const Icon(Icons.layers_outlined),
            tooltip: 'settings.secondary_bg_on'.tr(),
          ),
          ButtonSegment(
            value: SecondaryBackgroundMode.auto,
            label: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'settings.secondary_bg_auto'.tr(),
          ),
          ButtonSegment(
            value: SecondaryBackgroundMode.off,
            label: const Icon(Icons.layers_clear_outlined),
            tooltip: 'settings.secondary_bg_off'.tr(),
          ),
        ],
        selected: {_settings.secondaryBackgroundMode},
        onSelectionChanged: (Set<SecondaryBackgroundMode> newSelection) {
          _updateSecondaryBackgroundMode(newSelection.first);
        },
        showSelectedIcon: false,
      ),
    );
  }

  Widget _buildColorSelector({
    required Color current,
    required ValueChanged<Color> onSelect,
  }) {
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Presets
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'settings.color_presets'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _presets.map((color) {
              final isSelected = current.value == color.value;
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.check_circle,
                      color: color.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Custom picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.color_lens_outlined),
              label: Text('settings.custom_color'.tr()),
              onPressed: () async {
                final picked = await _pickColor(context, initial: current);
                if (picked != null) {
                  onSelect(picked);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Color?> _pickColor(
    BuildContext context, {
    required Color initial,
  }) async {
    Color temp = initial;
    int r = temp.red;
    int g = temp.green;
    int b = temp.blue;

    return showDialog<Color>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('settings.custom_color'.tr()),
          content: StatefulBuilder(
            builder: (context, setState) {
              temp = Color.fromARGB(255, r, g, b);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: temp,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sliderRow('R', r, (v) => setState(() => r = v)),
                  _sliderRow('G', g, (v) => setState(() => g = v)),
                  _sliderRow('B', b, (v) => setState(() => b = v)),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text('settings.close'.tr()),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(Color.fromARGB(255, r, g, b)),
              child: Text('settings.update'.tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _sliderRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text(label)),
        Expanded(
          child: Slider(
            min: 0,
            max: 255,
            value: value.toDouble(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(value.toString(), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildPreview({required bool isDark}) {
    final primary = Color(_settings.primaryColor);
    final onSurface = isDark ? Colors.white : Colors.black;
    final surface = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader('settings.preview'.tr()),
        const SizedBox(height: 12),
        SettingsCard(
          backgroundColor: surface,
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 240),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Hello! This is a preview of how messages look.',
                      style: TextStyle(color: onSurface, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 240),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Looks amazing and very modern!',
                      style: TextStyle(
                        color: primary.computeLuminance() < 0.5
                            ? Colors.white
                            : Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
