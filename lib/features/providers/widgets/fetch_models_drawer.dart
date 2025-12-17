import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/models/ai_model.dart';
import 'model_card.dart';

class FetchModelsDrawer extends StatelessWidget {
  final List<AIModel> availableModels;
  final List<AIModel> selectedModels;
  final bool isFetchingModels;
  final VoidCallback onFetchModels;
  final Function(AIModel) onAddModel;
  final Function(AIModel) onRemoveModel;
  final Function(AIModel) onShowCapabilities;

  const FetchModelsDrawer({
    super.key,
    required this.availableModels,
    required this.selectedModels,
    required this.isFetchingModels,
    required this.onFetchModels,
    required this.onAddModel,
    required this.onRemoveModel,
    required this.onShowCapabilities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_download, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'settings.fetch_models'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Fetch Button Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFetchingModels)
                      const LinearProgressIndicator()
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              availableModels.isEmpty
                                  ? 'settings.no_models_fetched'.tr()
                                  : '${availableModels.length} ${'settings.models_available'.tr()}',
                              style: TextStyle(
                                color: availableModels.isEmpty
                                    ? Colors.grey
                                    : Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: onFetchModels,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text('settings.fetch'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Models List
          Expanded(
            child: availableModels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'settings.tap_to_fetch_models'.tr(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: availableModels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final model = availableModels[index];
                      final isSelected = selectedModels.any(
                        (m) => m.name == model.name,
                      );

                      return ModelCard(
                        model: model,
                        onTap: () => onShowCapabilities(model),
                        trailing: IconButton(
                          icon: Icon(
                            isSelected ? Icons.close : Icons.add_circle,
                            color: isSelected ? Colors.red : Colors.green,
                            size: 24,
                          ),
                          onPressed: () {
                            if (isSelected) {
                              onRemoveModel(model);
                            } else {
                              onAddModel(model);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
