import 'package:flutter/material.dart';

/// Thẻ hiển thị tài nguyên dạng lưới (Grid) theo Material 3.
/// Dùng chung cho providers/agents/tts/mcp.
class GridCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;

  const GridCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.iconColor,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 12,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = iconColor ?? theme.colorScheme.primary;

    Widget cardBody = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: primary,
          ),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    // Nếu có menu hành động, hiển thị nút 3 chấm ở góc trên bên phải
    if (onEdit != null || onDelete != null) {
      cardBody = Stack(
        children: [
          Positioned.fill(child: cardBody),
          Positioned(
            top: 4,
            right: 4,
            child: _ActionMenu(
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: cardBody,
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ActionMenu({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case _MenuAction.edit:
            onEdit?.call();
            break;
          case _MenuAction.delete:
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_MenuAction>>[];
        if (onEdit != null) {
          items.add(
            PopupMenuItem(
              value: _MenuAction.edit,
              child: Row(
                children: const [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
          );
        }
        if (onDelete != null) {
          items.add(
            PopupMenuItem(
              value: _MenuAction.delete,
              child: Row(
                children: const [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete'),
                ],
              ),
            ),
          );
        }
        return items;
      },
    );
  }
}

enum _MenuAction { edit, delete }

/// Nút action trên AppBar để chuyển đổi giữa List và Grid theo Material Icons.
class ViewToggleAction extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;
  final String? listTooltip;
  final String? gridTooltip;

  const ViewToggleAction({
    super.key,
    required this.isGrid,
    required this.onChanged,
    this.listTooltip = 'List view',
    this.gridTooltip = 'Grid view',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isGrid ? listTooltip : gridTooltip,
      icon: Icon(isGrid ? Icons.view_list : Icons.grid_view_outlined),
      onPressed: () => onChanged(!isGrid),
    );
  }
}

/// Nút action trên AppBar để thêm tài nguyên theo Material Icons.
class AddAction extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const AddAction({
    super.key,
    required this.onPressed,
    this.tooltip = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: const Icon(Icons.add),
      onPressed: onPressed,
    );
  }
}