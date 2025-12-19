import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/models/ai_model.dart';
import '../../../core/models/provider.dart';
import '../widgets/fetch_models_drawer.dart';
import '../widgets/model_card.dart';
import 'add_provider_viewmodel.dart';
import '../../../core/widgets/dropdown.dart';

class AddProviderScreen extends StatefulWidget {
  final Provider? provider;

  const AddProviderScreen({super.key, this.provider});

  @override
  State<AddProviderScreen> createState() => _AddProviderScreenState();
}

class _AddProviderScreenState extends State<AddProviderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AddProviderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _viewModel = AddProviderViewModel();
    _viewModel.initialize(widget.provider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _showFetchModelsDrawer,
              icon: const Icon(Icons.cloud_download),
              label: Text('settings.fetch_models'.tr()),
            )
          : null,
      appBar: AppBar(
        title: Text(
          widget.provider != null
              ? 'settings.edit_provider'.tr()
              : 'settings.add_provider'.tr(),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'settings.edit_tab'.tr()),
            Tab(text: 'settings.models_tab'.tr()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _viewModel.saveProvider(
              context,
              existingProvider: widget.provider,
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEditTab(), _buildModelsTab()],
      ),
    );
  }

  Widget _buildEditTab() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CommonDropdown<ProviderType>(
              value: _viewModel.selectedType,
              labelText: 'settings.provider_type'.tr(),
              options: ProviderType.values.map((type) {
                return DropdownOption<ProviderType>(
                  value: type,
                  label: type.name,
                  icon: Icon(_iconForProviderType(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _viewModel.updateSelectedType(value);
                  _updateNameForType(value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _viewModel.nameController,
              decoration: InputDecoration(
                labelText: 'settings.name'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _viewModel.apiKeyController,
              decoration: InputDecoration(
                labelText: 'settings.api_key'.tr(),
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _viewModel.baseUrlController,
              decoration: InputDecoration(
                labelText: 'settings.base_url'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('settings.custom_routes'.tr()),
              subtitle: Text(_viewModel.selectedType.name),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildCustomRoutesSection(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'settings.custom_headers'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _viewModel.addHeader,
                ),
              ],
            ),
            ..._viewModel.headers.asMap().entries.map((entry) {
              final index = entry.key;
              final header = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: header.key,
                        decoration: InputDecoration(
                          labelText: 'settings.header_key'.tr(),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: header.value,
                        decoration: InputDecoration(
                          labelText: 'settings.header_value'.tr(),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _viewModel.removeHeader(index),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCustomRoutesSection() {
    switch (_viewModel.selectedType) {
      case ProviderType.openai:
        return Column(
          children: [
            _routeField(
              _viewModel.openAIChatCompletionsRouteController,
              'settings.chat_completions_route'.tr(),
            ),
            const SizedBox(height: 8),
            _routeField(
              _viewModel.openAIModelsRouteOrUrlController,
              'settings.models_route_or_url'.tr(),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _routeField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  IconData _iconForProviderType(ProviderType type) {
    switch (type) {
      case ProviderType.google:
        return Icons.cloud;
      case ProviderType.openai:
        return Icons.api;
      case ProviderType.anthropic:
        return Icons.psychology_alt;
      case ProviderType.ollama:
        return Icons.memory;
    }
  }

  Widget _buildModelsTab() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Models Section Header
              Row(
                children: [
                  Icon(
                    Icons.model_training,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'settings.selected_models'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Selected Models List
              Expanded(
                child: _viewModel.selectedModels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.model_training,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).disabledColor.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'settings.no_models_selected'.tr(),
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'settings.tap_fab_to_add'.tr(),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).disabledColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _viewModel.selectedModels.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final model = _viewModel.selectedModels[index];
                          return ModelCard(
                            model: model,
                            onTap: () => _showModelCapabilities(model),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _viewModel.removeModel(model.name),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFetchModelsDrawer() {
    // Bắt đầu fetch ngay khi ấn FAB để kết quả hiển thị tức thời trong drawer
    _viewModel.fetchModels(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FetchModelsDrawer(
        viewModel: _viewModel,
        onShowCapabilities: _showModelCapabilities,
      ),
    );
  }

  void _updateNameForType(ProviderType type) {
    if (_viewModel.nameController.text == 'Google' ||
        _viewModel.nameController.text == 'OpenAI' ||
        _viewModel.nameController.text == 'Anthropic') {
      switch (type) {
        case ProviderType.google:
          _viewModel.nameController.text = 'Google';
          break;
        case ProviderType.openai:
          _viewModel.nameController.text = 'OpenAI';
          break;
        case ProviderType.anthropic:
          _viewModel.nameController.text = 'Anthropic';
          break;
        case ProviderType.ollama:
          _viewModel.nameController.text = 'Ollama';
          break;
      }
    }
  }

  void _showModelCapabilities(AIModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${'settings.capabilities'.tr()}: ${model.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'settings.inputs'.tr()}: ${model.input.map((e) => e.name).join(", ")}',
            ),
            const SizedBox(height: 8),
            Text(
              '${'settings.outputs'.tr()}: ${model.output.map((e) => e.name).join(", ")}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('settings.close'.tr()),
          ),
        ],
      ),
    );
  }
}
