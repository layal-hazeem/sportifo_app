import 'package:flutter/material.dart';

class AppSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        required SnackBarType type,
        VoidCallback? onActionPressed,
        String? actionLabel,
      }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.withOpacity(0.85);
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.redAccent.withOpacity(0.85);
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning: // ✅ تمت إضافة الحالة هنا
        backgroundColor = Colors.orangeAccent.withOpacity(0.9);
        icon = Icons.warning_amber_rounded;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.grey[800]!.withOpacity(0.85);
        icon = Icons.info_outline;
        break;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (onActionPressed != null)
              TextButton(
                onPressed: onActionPressed,
                child: Text(
                  actionLabel ?? "Show",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ✅ تحديث الـ Enum ليشمل warning
enum SnackBarType { success, error, warning, info }