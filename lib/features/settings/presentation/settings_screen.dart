import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/routes.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SettingsSectionHeader('settings.general'.tr()),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.api,
                    title: 'settings.providers'.tr(),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.providers),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'settings.appearance'.tr(),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.appearance),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.tune,
                    title: 'settings.preferences'.tr(),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.preferences),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'settings.notifications'.tr(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsSectionHeader('settings.ai_features'.tr()),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.record_voice_over_outlined,
                    title: 'settings.tts'.tr(),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.tts),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.extension_outlined,
                    title: 'settings.mcp'.tr(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsSectionHeader('settings.about_section'.tr()),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'settings.info'.tr(),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.system_update_outlined,
                    title: 'settings.update'.tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
