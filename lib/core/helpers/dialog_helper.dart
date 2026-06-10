import 'package:flutter/material.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

/// تعريف أنواع الديالوغ المتاحة
enum DialogType { success, error, warning }

class DialogHelper {
  static void showCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    required DialogType type,
    String? confirmBtnText,
    VoidCallback? onConfirm,
  }) {
    final l10n = AppLocalizations.of(context)!;
    Color primaryColor;
    IconData icon;

    switch (type) {
      case DialogType.success:
        primaryColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case DialogType.error:
        primaryColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case DialogType.warning:
        primaryColor = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // يجب التفاعل مع الديالوغ لإغلاقه
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Column(
            children: [
              Icon(icon, color: primaryColor, size: 50),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // زر الإلغاء الافتراضي
              child: Text(l10n.cancel, style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الديالوغ أولاً
                if (onConfirm != null) onConfirm(); // تنفيذ العملية المطلوبة
              },
              child: Text(
                confirmBtnText ?? l10n.agreed,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}
