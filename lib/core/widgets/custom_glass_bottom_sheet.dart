import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';

class CustomGlassBottomSheet extends StatelessWidget {
  final Widget child;
  final Widget? topHeader; // اختياري: يوضع فوق البطاقة في الجزء الضبابي (مثل صور الإعلان)
  final Widget? stickyBottomButton; // اختياري: زر ثابت بأسفل الشاشة
  final double? fixedHeight;
  final EdgeInsetsGeometry? contentPadding;

  const CustomGlassBottomSheet({
    super.key,
    required this.child,
    this.topHeader,
    this.stickyBottomButton,
    this.fixedHeight,
    this.contentPadding,
  });

  /// 🔥 الدالة الوحيدة والموحدة لفتح أي Bottom Sheet في التطبيق بالكامل
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    Widget? topHeader,
    Widget? stickyBottomButton,
    double? fixedHeight,
    bool isDismissible = true,
    bool enableDrag = true,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      // تعتيم خفيف موحد لأن الضبابية ستغطي الخلفية
      barrierColor: Colors.black.withValues(alpha: 0.15),
      builder: (_) => BackdropFilter(
        // 🔥 ضبابية موحدة للشاشة الخلفية في كل التطبيق
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: CustomGlassBottomSheet(
          fixedHeight: fixedHeight,
          topHeader: topHeader,
          stickyBottomButton: stickyBottomButton,
          contentPadding: contentPadding,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    final bgColor = isDark ? const Color(0xFF1C1C1E) : context.backgroundColor;

    // 1. تصميم مقبض السحب الموحد (Drag Handle)
    Widget dragHandle = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 45,
          height: 5,
          decoration: BoxDecoration(
            color: topHeader != null
                ? Colors.white.withValues(alpha: 0.6)
                : (isDark
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );

    // 2. حاوية المحتوى الرئيسية الموحدة
    Widget mainContainer = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: fixedHeight != null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (topHeader == null) dragHandle,
          Flexible(
            child: Padding(
              padding: contentPadding ??
                  EdgeInsets.fromLTRB(
                    20,
                    topHeader != null ? 28 : 8,
                    20,
                    (stickyBottomButton != null ? 100 : 16) + bottomPadding,
                  ),
              child: child,
            ),
          ),
        ],
      ),
    );

    // 3. في حال وجود topHeader (مثل سلايدر الإعلان) أو زر سفلي ثابت
    Widget finalSheet = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (topHeader != null)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.13),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  dragHandle,
                  topHeader!,
                  const SizedBox(height: 16),
                  mainContainer,
                ],
              ),
            ),
          )
        else
          mainContainer,

        if (stickyBottomButton != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + bottomPadding),
              color: bgColor,
              child: stickyBottomButton!,
            ),
          ),
      ],
    );

    if (fixedHeight != null) {
      return FractionallySizedBox(heightFactor: fixedHeight, child: finalSheet);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      child: finalSheet,
    );
  }
}