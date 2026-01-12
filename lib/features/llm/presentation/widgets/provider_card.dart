import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

/// Widget hiển thị provider dạng card trong grid view hoặc list view
class ProviderCard extends StatelessWidget {
  final LlmProviderInfo provider;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ItemCardLayout layout;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.layout = ItemCardLayout.grid,
  });

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: layout,
      icon: buildIcon(provider.name),
      title: provider.name,
      subtitle: tl('${provider.type.name} Compatible'),
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}