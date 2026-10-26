import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';

class CustomGlassBottomSheet extends StatelessWidget {
  final Widget child;

  /// إذا حددت [fixedHeight] يستخدمها كنسبة من الشاشة (0.0 → 1.0).
  /// إذا تركتها null يتمدد البوتوم شيت حسب المحتوى (مع حد أقصى 90%).
  final double? fixedHeight;

  const CustomGlassBottomSheet({
    super.key,
    required this.child,
    this.fixedHeight,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? fixedHeight,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: CustomGlassBottomSheet(fixedHeight: fixedHeight, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    Widget sheet = Container(
      decoration: BoxDecoration(
        color: context.backgroundColor.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: fixedHeight != null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // ── Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.textColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          // ── Content
          Flexible(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
              child: child,
            ),
          ),
        ],
      ),
    );

    if (fixedHeight != null) {
      return FractionallySizedBox(
        heightFactor: fixedHeight,
        child: sheet,
      );
    }

    // wrap with max height constraint (90% of screen)
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: sheet,
    );
  }
}