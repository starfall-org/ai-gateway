import 'dart:async';
import 'package:flutter/material.dart';

/// Kiểu hiển thị của snackbar
enum AppSnackBarType { success, error, warning, info }

/// Widget Snackbar dùng chung với thiết kế đẹp và animation
class AppSnackBar extends StatelessWidget {
  final String message;
  final AppSnackBarType type;
  final Duration? duration;
  final VoidCallback? onUndo;
  final String? undoLabel;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppSnackBar({
    super.key,
    required this.message,
    this.type = AppSnackBarType.info,
    this.duration,
    this.onUndo,
    this.undoLabel,
    this.onAction,
    this.actionLabel,
  });

  /// Hiển thị snackbar thành công
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onUndo,
    String? undoLabel,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      AppSnackBar(
        message: message,
        type: AppSnackBarType.success,
        duration: duration,
        onUndo: onUndo,
        undoLabel: undoLabel,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Hiển thị snackbar lỗi
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onUndo,
    String? undoLabel,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      AppSnackBar(
        message: message,
        type: AppSnackBarType.error,
        duration: duration,
        onUndo: onUndo,
        undoLabel: undoLabel,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Hiển thị snackbar cảnh báo
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onUndo,
    String? undoLabel,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      AppSnackBar(
        message: message,
        type: AppSnackBarType.warning,
        duration: duration,
        onUndo: onUndo,
        undoLabel: undoLabel,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Hiển thị snackbar thông tin
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    VoidCallback? onUndo,
    String? undoLabel,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      AppSnackBar(
        message: message,
        type: AppSnackBarType.info,
        duration: duration,
        onUndo: onUndo,
        undoLabel: undoLabel,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Entry hiện tại của overlay để có thể xóa
  static OverlayEntry? _currentOverlayEntry;

  /// Phương thức nội bộ để hiển thị snackbar dùng Overlay
  static void _showSnackBar(BuildContext context, AppSnackBar snackBar) {
    // Xóa snackbar hiện tại nếu có
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _OverlaySnackBar(
        snackBar: snackBar,
        onDismiss: () {
          overlayEntry.remove();
          if (_currentOverlayEntry == overlayEntry) {
            _currentOverlayEntry = null;
          }
        },
      ),
    );

    _currentOverlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    // Tự động xóa sau duration
    final duration = snackBar.duration ?? const Duration(seconds: 4);
    Timer(duration, () {
      if (_currentOverlayEntry == overlayEntry) {
        overlayEntry.remove();
        _currentOverlayEntry = null;
      }
    });
  }

  /// Lấy màu sắc theo kiểu snackbar
  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case AppSnackBarType.success:
        return colorScheme.primary.withValues(alpha: 0.9);
      case AppSnackBarType.error:
        return colorScheme.error.withValues(alpha: 0.9);
      case AppSnackBarType.warning:
        return Colors.orange.withValues(alpha: 0.9);
      case AppSnackBarType.info:
        return colorScheme.secondary.withValues(alpha: 0.9);
    }
  }

  /// Lấy icon theo kiểu snackbar
  IconData _getIcon() {
    switch (type) {
      case AppSnackBarType.success:
        return Icons.check_circle_outline;
      case AppSnackBarType.error:
        return Icons.error_outline;
      case AppSnackBarType.warning:
        return Icons.warning_amber_outlined;
      case AppSnackBarType.info:
        return Icons.info_outline;
    }
  }

  /// Lấy màu text theo kiểu snackbar
  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case AppSnackBarType.success:
        return colorScheme.onPrimary;
      case AppSnackBarType.error:
        return colorScheme.onError;
      case AppSnackBarType.warning:
      case AppSnackBarType.info:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);
    final icon = _getIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Nội dung message
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Nút action hoặc undo
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color:
                      Theme.of(context).inputDecorationTheme.hintStyle?.color ??
                      Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Text(
                actionLabel!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
          ] else if (onUndo != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onUndo,
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color:
                      Theme.of(context).inputDecorationTheme.hintStyle?.color ??
                      Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Text(
                undoLabel ?? 'Hoàn tác',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension để dễ dàng sử dụng snackbar từ bất kỳ đâu
extension AppSnackBarExtension on BuildContext {
  void showSuccessSnackBar(
    String message, {
    Duration? duration,
    VoidCallback? onUndo,
    String? undoLabel,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    AppSnackBar.showSuccess(
      this,
      message,
      duration: duration,
      onUndo: onUndo,
      undoLabel: undoLabel,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  void showErrorSnackBar(
    String message, {
    Duration? duration,
    VoidCallback? onUndo,
    String? undoLabel,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    AppSnackBar.showError(
      this,
      message,
      duration: duration,
      onUndo: onUndo,
      undoLabel: undoLabel,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  void showWarningSnackBar(
    String message, {
    Duration? duration,
    VoidCallback? onUndo,
    String? undoLabel,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    AppSnackBar.showWarning(
      this,
      message,
      duration: duration,
      onUndo: onUndo,
      undoLabel: undoLabel,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  void showInfoSnackBar(
    String message, {
    Duration? duration,
    VoidCallback? onUndo,
    String? undoLabel,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    AppSnackBar.showInfo(
      this,
      message,
      duration: duration,
      onUndo: onUndo,
      undoLabel: undoLabel,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}

/// Widget overlay để hiển thị snackbar trên mọi widget
class _OverlaySnackBar extends StatefulWidget {
  final AppSnackBar snackBar;
  final VoidCallback onDismiss;

  const _OverlaySnackBar({required this.snackBar, required this.onDismiss});

  @override
  State<_OverlaySnackBar> createState() => _OverlaySnackBarState();
}

class _OverlaySnackBarState extends State<_OverlaySnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(onTap: _dismiss, child: widget.snackBar),
        ),
      ),
    );
  }
}
