import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

enum DialogType { success, error, warning, input }

class DialogHelper {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required String title,
    String? message,
    String? hintText,
    TextEditingController? controller,
    required DialogType type,
    String? confirmBtnText,
    String? cancelBtnText,
    bool barrierDismissible = true,
    Function(String)? onConfirmWithInput,
    VoidCallback? onConfirm,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final config = _DialogConfig.fromType(type);

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => _AppDialog(
        title: title,
        message: message,
        hintText: hintText,
        controller: controller,
        config: config,
        confirmBtnText: confirmBtnText ?? l10n.agreed,
        cancelBtnText: cancelBtnText ?? l10n.cancel,
        onConfirm: onConfirm,
        onConfirmWithInput: onConfirmWithInput,
        isInput: type == DialogType.input,
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
      case DialogType.success:
        return const _DialogConfig(
          accentColor: Color(0xFF22C55E),
          icon: Icons.check_circle_rounded,
        );
      case DialogType.error:
        return const _DialogConfig(
          accentColor: Color(0xFFEF4444),
          icon: Icons.cancel_rounded,
        );
      case DialogType.warning:
        return const _DialogConfig(
          accentColor: AppColors.primaryBtn,
          icon: Icons.warning_rounded,
        );
      case DialogType.input:
        return const _DialogConfig(
          accentColor: AppColors.primaryBtn,
          icon: Icons.edit_rounded,
        );
    }
  }
}

// ─── Dialog Widget ─────────────────────────────────────────────────────────────

class _AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String? hintText;
  final TextEditingController? controller;
  final _DialogConfig config;
  final String confirmBtnText;
  final String cancelBtnText;
  final VoidCallback? onConfirm;
  final Function(String)? onConfirmWithInput;
  final bool isInput;

  const _AppDialog({
    required this.title,
    required this.message,
    required this.hintText,
    required this.controller,
    required this.config,
    required this.confirmBtnText,
    required this.cancelBtnText,
    required this.onConfirm,
    required this.onConfirmWithInput,
    required this.isInput,
  });

  @override
  Widget build(BuildContext context) {
    final bg = context.backgroundColor;
    final textColor = context.textColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top accent strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: config.accentColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Icon
                  if (!isInput) ...[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: config.accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(config.icon, color: config.accentColor, size: 32),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // ── Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  // ── Message or Input
                  if (message != null && !isInput) ...[
                    const SizedBox(height: 10),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (isInput) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(color: AppColors.hintText),
                        filled: true,
                        fillColor: context.secondaryBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: config.accentColor, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  // ── Actions
                  Row(
                    children: [
                      Expanded(
                        child: _DialogButton(
                          label: cancelBtnText,
                          onTap: () => Navigator.of(context).pop(),
                          isOutlined: true,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogButton(
                          label: confirmBtnText,
                          onTap: () {
                            Navigator.of(context).pop();
                            if (isInput && onConfirmWithInput != null) {
                              onConfirmWithInput!(controller?.text ?? '');
                            } else {
                              onConfirm?.call();
                            }
                          },
                          color: config.accentColor,
                        ),
                      ),
                    ],
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
  final VoidCallback onTap;
  final Color color;
  final bool isOutlined;

  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(14),
          border: isOutlined ? Border.all(color: color, width: 1.5) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isOutlined ? color : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}