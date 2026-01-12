import 'package:flutter/material.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

class ModelCard extends StatelessWidget {
  final LlmModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModelCard({super.key, required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.displayName,
      subtitle: _buildSubtitle(),
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: model.icon != null
          ? buildIcon(model.icon!)
          : buildIcon(model.id),
      ),
      subtitleWidget: _buildOriginSpecificInfo(context),
      leading: _buildTypeTag(context),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _buildSubtitle() {
    if (model.origin is BasicModel) {
      final basicModel = model.origin as BasicModel;
      return 'by ${basicModel.ownedBy}';
    } else if (model.origin is GitHubModel) {
      final githubModel = model.origin as GitHubModel;
      return githubModel.id;
    } else if (model.origin is OllamaModel) {
      final ollamaModel = model.origin as OllamaModel;
      return 'Model: ${ollamaModel.model}';
    } else if (model.origin is GoogleAiModel) {
      final googleModel = model.origin as GoogleAiModel;
      return 'Top-K: ${googleModel.topK}, Top-P: ${googleModel.topP}';
    }
    return model.id;
  }

  Widget? _buildOriginSpecificInfo(BuildContext context) {
    final tags = <Widget>[];

    if (model.origin is OllamaModel) {
      final ollamaModel = model.origin as OllamaModel;
      tags.addAll([
        _ModelCardHelpers.buildTextTag(
          context,
          ollamaModel.parameterSize,
          Theme.of(context).colorScheme.tertiary,
        ),
        _ModelCardHelpers.buildTextTag(
          context,
          ollamaModel.quantizationLevel,
          Theme.of(context).colorScheme.secondary,
        ),
      ]);
    } else if (model.origin is GoogleAiModel) {
      final googleModel = model.origin as GoogleAiModel;
      
      // Thinking capability
      if (googleModel.thinking) {
        tags.add(
          _ModelCardHelpers.buildTextTag(
            context,
            'Thinking',
            Theme.of(context).colorScheme.primary,
          ),
        );
      }

      // Supported generation methods
      for (var method in googleModel.supportedGenerationMethods) {
        tags.add(
          _ModelCardHelpers.buildTextTag(
            context,
            method,
            Theme.of(context).colorScheme.secondary,
          ),
        );
      }

      // Token limits
      tags.addAll([
        _ModelCardHelpers.buildTextTag(
          context,
          'In: ${_ModelCardHelpers.formatNumber(googleModel.inputTokenLimit)}',
          Theme.of(context).colorScheme.tertiary,
        ),
        _ModelCardHelpers.buildTextTag(
          context,
          'Out: ${_ModelCardHelpers.formatNumber(googleModel.outputTokenLimit)}',
          Theme.of(context).colorScheme.tertiary,
        ),
        _ModelCardHelpers.buildTextTag(
          context,
          'T: ${googleModel.temperature}-${googleModel.maxTemperature}',
          Theme.of(context).colorScheme.tertiary,
        ),
      ]);
    }

    return tags.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Wrap(spacing: 4, runSpacing: 4, children: tags),
          )
        : null;
  }

  Widget _buildTypeTag(BuildContext context) {
    IconData iconData;
    Color color = Theme.of(context).colorScheme.primary;
    
    switch (model.type) {
      case LlmModelType.chat:
        iconData = Icons.chat;
        break;
      case LlmModelType.image:
        iconData = Icons.image;
        color = Theme.of(context).colorScheme.secondary;
        break;
      case LlmModelType.audio:
        iconData = Icons.audiotrack;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case LlmModelType.video:
        iconData = Icons.videocam;
        color = Theme.of(context).colorScheme.error;
        break;
      case LlmModelType.embed:
        iconData = Icons.data_array;
        color = Theme.of(context).colorScheme.outline;
        break;
    }
    
    return _ModelCardHelpers.buildTag(
      context,
      Icon(iconData, size: 16),
      color,
    );
  }
}


// ============================================================================
// Helper Class
// ============================================================================

/// Helper methods for building model card components
class _ModelCardHelpers {
  _ModelCardHelpers._(); // Private constructor to prevent instantiation

  /// Format large numbers (e.g., 1000000 → "1.0M")
  static String formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  /// Format parameters (e.g., 7000000000 → "7B")
  static String formatParameters(int params) {
    if (params >= 1000000000) {
      return '${(params / 1000000000).toStringAsFixed(0)}B';
    } else if (params >= 1000000) {
      return '${(params / 1000000).toStringAsFixed(0)}M';
    } else if (params >= 1000) {
      return '${(params / 1000).toStringAsFixed(0)}K';
    }
    return params.toString();
  }

  /// Build a colored tag widget
  static Widget buildTag(BuildContext context, Widget label, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final boxColor = isDark
        ? Color.lerp(color, theme.colorScheme.surface, 0.7)!
        : Color.lerp(color, theme.colorScheme.onSurface, 0.5)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: boxColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.3)),
      ),
      child: label,
    );
  }

  /// Build a text tag widget
  static Widget buildTextTag(BuildContext context, String label, Color color) {
    return buildTag(
      context,
      Text(label, style: const TextStyle(fontSize: 11)),
      color,
    );
  }
}
