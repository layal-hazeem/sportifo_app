import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

enum DialogType { confirm, delete, warning, success }

class DialogHelper {
  static Future<bool?> showCustomDialog({
    required BuildContext context,
    required String title,
    String? message,
    required DialogType type,
    String? confirmBtnText,
    String? cancelBtnText,
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final config = _DialogConfig.fromType(type);

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => _AppDialog(
        title: title,
        message: message,
        config: config,
        confirmBtnText: confirmBtnText ?? l10n.agreed,
        cancelBtnText: cancelBtnText ?? l10n.cancel,
        onConfirm: onConfirm,
      ),
    );
  }
}

// ─── Config ────────────────────────────────────────────────────────────────────

class _DialogConfig {
  final Color accentColor;
  final IconData icon;

  const _DialogConfig({required this.accentColor, required this.icon});

  factory _DialogConfig.fromType(DialogType type) {
    switch (type) {
      case DialogType.delete:
        return const _DialogConfig(
          accentColor: Color(0xFFEF4444),
          icon: Icons.delete_outline_rounded,
        );
      case DialogType.warning:
        return const _DialogConfig(
          accentColor: AppColors.primaryBtn,
          icon: Icons.warning_amber_rounded,
        );
      case DialogType.success:
        return const _DialogConfig(
          accentColor: Color(0xFF22C55E),
          icon: Icons.check_circle_outline_rounded,
        );
      case DialogType.confirm:
        return const _DialogConfig(
          accentColor: AppColors.primaryBtn,
          icon: Icons.help_outline_rounded,
        );
    }
  }
}

// ─── Dialog ────────────────────────────────────────────────────────────────────

class _AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final _DialogConfig config;
  final String confirmBtnText;
  final String cancelBtnText;
  final VoidCallback? onConfirm;

  const _AppDialog({
    required this.title,
    required this.message,
    required this.config,
    required this.confirmBtnText,
    required this.cancelBtnText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.45);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon + Title + Message
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: config.accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      config.icon,
                      color: config.accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  // Message
                  if (message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Divider
            Divider(height: 1, color: dividerColor),

            // ── Buttons
            IntrinsicHeight(
              child: Row(
                children: [
                  // Cancel
                  Expanded(
                    child: _DialogButton(
                      label: cancelBtnText,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  VerticalDivider(width: 1, color: dividerColor),
                  // Confirm
                  Expanded(
                    child: _DialogButton(
                      label: confirmBtnText,
                      color: config.accentColor,
                      fontWeight: FontWeight.w700,
                      onTap: () {
                        Navigator.of(context).pop(true);
                        onConfirm?.call();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Button ────────────────────────────────────────────────────────────────────

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final FontWeight fontWeight;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.fontWeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}