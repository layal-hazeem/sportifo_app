import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: l10n.resetPasswordTitle,
                subtitle: null, // لا نحتاج وصف هنا
              ),
              const SizedBox(height: 50),

              Text(l10n.newPassword,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.labelFontSize)
              ),
              const SizedBox(height: 15),
              CustomNeumorphicField(
                  hint: l10n.passwordHint,
                  icon: Icons.lock_outline,
                  isPassword: true
              ),

              const SizedBox(height: 30),

              Text(l10n.confirmPassword,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.labelFontSize)
              ),
              const SizedBox(height: 15),
              CustomNeumorphicField(
                  hint: l10n.passwordHint,
                  icon: Icons.lock_reset,
                  isPassword: true
              ),

              const SizedBox(height: 60),
              CustomAuthButton(
                text: l10n.updatePassword, // "Update Password"
                onPressed: () {
                  // بعد النجاح نعود لصفحة تسجيل الدخول
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}