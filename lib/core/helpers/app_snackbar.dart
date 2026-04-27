import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSnackBar {
  // دالة ثابتة يمكن استدعاؤها من أي مكان في التطبيق
  static void show(BuildContext context, {required String message, bool isError = true}) {

    // 1. حماية إضافية: التأكد من أن الشاشة ما زالت مفتوحة قبل إظهار السناك بار
    if (!context.mounted) return;

    // 2. إخفاء أي سناك بار قديم فوراً لكي لا تتراكم الرسائل فوق بعضها
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 3. إظهار السناك بار الجديد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.primaryBtn,
        behavior: SnackBarBehavior.floating, // سناك بار عائم
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // حواف دائرية
        ),
        margin: const EdgeInsets.all(20), // مسافة من الأطراف
        elevation: 0,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}