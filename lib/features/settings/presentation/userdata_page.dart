import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/userdata_controller.dart';
import 'package:multigateway/features/settings/presentation/widgets/userdata/data_management_section.dart';
import 'package:multigateway/features/settings/presentation/widgets/userdata/data_overview_card.dart';
import 'package:multigateway/features/settings/presentation/widgets/userdata/privacy_controls_section.dart';
import 'package:multigateway/features/settings/presentation/widgets/userdata/storage_controls_section.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals_flutter.dart';

/// Màn hình điều khiển dữ liệu cho phép quản lý và kiểm soát dữ liệu ứng dụng
class DataControlsScreen extends StatelessWidget {
  const DataControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UserDataControllerScope(
      child: const _DataControlsView(),
    );
  }
}

class _DataControlsView extends StatelessWidget {
  const _DataControlsView();

  @override
  Widget build(BuildContext context) {
    final controller = UserDataControllerProvider.of(context);
    final initFuture = UserDataControllerProvider.initializationFutureOf(context);
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
              tl('Data Controls'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Manage and control data'),
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
        child: FutureBuilder<void>(
          future: initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Watch((context) {
              final isBusy = controller.isProcessing.value;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataOverviewCard(
                      conversationCount: controller.conversationCount.value,
                      profileCount: controller.profileCount.value,
                      providerCount: controller.providerCount.value,
                    ),
                    const SizedBox(height: 24),
                    AbsorbPointer(
                      absorbing: isBusy,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DataManagementSection(
                            onBackupTap: () => _handleBackup(context, controller),
                            onRestoreTap: () => _handleRestore(context, controller),
                            onExportTap: () => _handleExport(context, controller),
                          ),
                          const SizedBox(height: 24),
                          PrivacyControlsSection(
                            onAnonymizeTap: () => _handleAnonymize(context, controller),
                            onDeleteAllTap: () => _handleDeleteAll(context, controller),
                          ),
                          const SizedBox(height: 24),
                          StorageControlsSection(
                            onCleanCacheTap: () => _handleCleanCache(context, controller),
                            onManageFilesTap: () => _handleManageFiles(context, controller),
                          ),
                        ],
                      ),
                    ),
                    if (isBusy) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

/// Provider + scope để khởi tạo/dispose controller
class UserDataControllerScope extends StatefulWidget {
  final Widget child;
  const UserDataControllerScope({super.key, required this.child});

  @override
  State<UserDataControllerScope> createState() => _UserDataControllerScopeState();
}

class _UserDataControllerScopeState extends State<UserDataControllerScope> {
  late final UserDataController _controller;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = UserDataController();
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserDataControllerProvider(
      controller: _controller,
      initializationFuture: _initFuture,
      child: widget.child,
    );
  }
}

class UserDataControllerProvider extends InheritedWidget {
  final UserDataController controller;
  final Future<void> initializationFuture;

  const UserDataControllerProvider({
    super.key,
    required this.controller,
    required this.initializationFuture,
    required super.child,
  });

  static UserDataController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<UserDataControllerProvider>();
    assert(provider != null, 'UserDataControllerProvider not found in context');
    return provider!.controller;
  }

  static Future<void> initializationFutureOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<UserDataControllerProvider>();
    assert(provider != null, 'UserDataControllerProvider not found in context');
    return provider!.initializationFuture;
  }

  @override
  bool updateShouldNotify(covariant UserDataControllerProvider oldWidget) {
    return false;
  }
}

/// Handlers cho các hành động (giữ Stateless UI, logic nằm ở controller)
Future<void> _handleBackup(
  BuildContext context,
  UserDataController controller,
) async {
  await controller.backupData();
  if (!context.mounted) return;
  context.showInfoSnackBar(tl('Data backup started'));
}

Future<void> _handleRestore(
  BuildContext context,
  UserDataController controller,
) async {
  await controller.restoreData();
  if (!context.mounted) return;
  context.showInfoSnackBar(tl('Data restore started'));
}

Future<void> _handleExport(
  BuildContext context,
  UserDataController controller,
) async {
  await controller.exportData();
  if (!context.mounted) return;
  context.showInfoSnackBar(tl('Data export started'));
}

Future<void> _handleAnonymize(
  BuildContext context,
  UserDataController controller,
) async {
  await controller.anonymizeData();
  if (!context.mounted) return;
  context.showInfoSnackBar(tl('Data anonymization started'));
}

Future<void> _handleDeleteAll(
  BuildContext context,
  UserDataController controller,
) async {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(tl('Confirm Delete All')),
      content: Text(
        tl(
          'This action will permanently delete all chat data and cached translations. Are you sure you want to continue?',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(tl('Cancel')),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await controller.deleteAllData();
            if (!context.mounted) return;
            context.showSuccessSnackBar(tl('All data deleted'));
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(
              color:
                  Theme.of(context).inputDecorationTheme.hintStyle?.color ??
                      Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: Text(tl('Delete')),
        ),
      ],
    ),
  );
}

Future<void> _handleCleanCache(
  BuildContext context,
  UserDataController controller,
) async {
  await controller.cleanCache();
  if (!context.mounted) return;
  context.showSuccessSnackBar(tl('Cache cleaned'));
}

Future<void> _handleManageFiles(
  BuildContext context,
  UserDataController controller,
) async {
  await controller.manageFiles();
  if (!context.mounted) return;
  context.showInfoSnackBar(tl('File manager opened'));
}
