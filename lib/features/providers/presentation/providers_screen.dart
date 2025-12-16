import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/provider_repository.dart';
import '../../../core/models/provider.dart';
import '../../../core/widgets/resource_tile.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/grid_card.dart';
import 'add_provider_screen.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  List<Provider> _providers = [];
  bool _isLoading = true;
  bool _isGridView = false;
  late ProviderRepository _repository;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    _repository = await ProviderRepository.init();
    setState(() {
      _providers = _repository.getProviders();
      _isLoading = false;
    });
  }

  Future<void> _deleteProvider(String name) async {
    final provider = _providers.firstWhere((p) => p.name == name);
    await _repository.deleteProvider(name);
    _loadProviders();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.provider_deleted'.tr(args: [provider.name])),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.providers'.tr()),
        actions: [
          AddAction(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProviderScreen(),
                ),
              );
              if (result == true) {
                _loadProviders();
              }
            },
          ),
          ViewToggleAction(
            isGrid: _isGridView,
            onChanged: (val) {
              setState(() {
                _isGridView = val;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providers.isEmpty
          ? EmptyState(
              message: 'settings.no_providers'.tr(),
              actionLabel: 'Add Provider',
              onAction: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProviderScreen(),
                  ),
                );
                if (result == true) {
                  _loadProviders();
                }
              },
            )
          : _isGridView
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: _providers.length,
              itemBuilder: (context, index) =>
                  _buildProviderCard(_providers[index]),
            )
          : ListView.builder(
              // Changed to Builder for better perf
              itemCount: _providers.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) =>
                  _buildProviderTile(_providers[index]),
            ),
    );
  }

  Widget _buildProviderTile(Provider provider) {
    return ResourceTile(
      title: provider.name,
      subtitle: 'settings.models_count'.tr(
        namedArgs: {'count': provider.models.length.toString()},
      ),
      leadingIcon: _getProviderIcon(provider.type),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProviderScreen(provider: provider),
          ),
        );
        if (result == true) {
          _loadProviders();
        }
      },
      onDelete: () => _confirmDelete(provider),
      onEdit: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProviderScreen(provider: provider),
          ),
        );
        if (result == true) {
          _loadProviders();
        }
      },
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return GridCard(
      icon: _getProviderIcon(provider.type),
      title: provider.name,
      subtitle: 'settings.models_count'.tr(
        namedArgs: {'count': provider.models.length.toString()},
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProviderScreen(provider: provider),
          ),
        );
        if (result == true) {
          _loadProviders();
        }
      },
      onEdit: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProviderScreen(provider: provider),
          ),
        );
        if (result == true) {
          _loadProviders();
        }
      },
      onDelete: () => _confirmDelete(provider),
    );
  }

  Future<void> _confirmDelete(Provider provider) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Provider',
      content: 'Are you sure you want to delete ${provider.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirm == true) {
      _deleteProvider(
        provider.name,
      ); // Using name as ID based on repo implementation
    }
  }

  IconData _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.googleGenAI:
        return Icons.android;
      case ProviderType.openAI:
        return Icons.smart_toy;
      case ProviderType.anthropic:
        return Icons.psychology;
      case ProviderType.ollama:
        return Icons.terminal;
    }
  }
}
