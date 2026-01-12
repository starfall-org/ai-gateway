import 'package:flutter/material.dart';

import 'package:multigateway/app/config/routes.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Settings'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Manage app settings'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SettingsTile(
              icon: Icons.palette_outlined,
              title: tl('Appearance'),
              subtitle: tl('Customize app appearance'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.appearance),
            ),
            SettingsTile(
              icon: Icons.tune,
              title: tl('Preferences'),
              subtitle: tl('General preferences'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.preferences),
            ),
            SettingsTile(
              icon: Icons.system_update_outlined,
              title: tl('Update'),
              subtitle: tl('Check and install updates'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.update),
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: tl('About'),
              subtitle: tl('Information and details'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            ),
            SettingsTile(
              icon: Icons.storage,
              title: tl('Data'),
              subtitle: tl('Manage and control data'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.userdata),
            ),
          ],
        ),
      ),
    );
  }
}
