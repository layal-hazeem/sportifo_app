import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        required SnackBarType type,
        VoidCallback? onActionPressed,
        String? actionLabel,
        Duration duration = const Duration(seconds: 3),
      }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = _iconFromType(type);

    messenger.showSnackBar(
      SnackBar(
        content: _SnackBarContent(
          message: message,
          icon: icon,
          isDark: isDark,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        duration: duration,
      ),
    );
  }

  static IconData _iconFromType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline_rounded;
      case SnackBarType.error:
        return Icons.error_outline_rounded;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const _SnackBarContent({
    required this.message,
    required this.icon,
    required this.isDark,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Dark mode: خلفية داكنة تقريباً أسود زي الانستا
    // Light mode: رمادي غامق
    final bgColor = isDark
        ? const Color(0xFF1C1C1C)
        : const Color(0xFF2D2D2D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          if (onActionPressed != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onActionPressed,
              child: Text(
                actionLabel ?? 'Action',
                style: const TextStyle(
                  color: AppColors.primaryBtn,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}