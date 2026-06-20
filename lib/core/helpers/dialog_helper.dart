import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

/// تعريف أنواع الديالوغ المتاحة
enum DialogType { success, error, warning, input }

class DialogHelper {
  static void showCustomDialog({
    required BuildContext context,
    required String title,
    String? message,
    String? hintText,
    TextEditingController? controller, // إضافة Controller
    required DialogType type,
    String? confirmBtnText,
    Function(String)? onConfirmWithInput,
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
        primaryColor = AppColors.primaryBtn;
        icon = Icons.warning_amber_rounded;
        break;
      case DialogType.input:
        primaryColor = AppColors.primaryBtn;
        icon = Icons.check_circle_outline;
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
          title: type == DialogType.input
              ? Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Column(
                  children: [
                    Icon(icon, color: primaryColor, size: 50),
                    Text(
                      title,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

          content: type == DialogType.input
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: hintText),
                )
              : Text(message ?? ""),

          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel, style: TextStyle(color: Colors.grey)),
            ),
            CustomAuthButton(
              text: confirmBtnText ?? l10n.agreed,
              isFullWidth: false,
              onPressed: () {
                Navigator.of(context).pop();
                if (type == DialogType.input && onConfirmWithInput != null) {
                  onConfirmWithInput(controller?.text ?? "");
                } else if (onConfirm != null) {
                  onConfirm();
                }
              },
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}
