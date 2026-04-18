import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.textDark)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  l10n.forgotPassword,
                  style: const TextStyle(fontSize: AppSizes.titleFontSize, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.forgotPasswordDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: AppSizes.hintFontSize, color: AppColors.hintText),
              ),
              const SizedBox(height: 50),
              Text(l10n.emailOrPhone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.labelFontSize)),
              const SizedBox(height: 15),
              CustomNeumorphicField(hint: l10n.emailHint, icon: Icons.email_outlined),
              const SizedBox(height: 40),
              CustomAuthButton(
                text: l10n.sendCode,
                onPressed: () {
                  // سننتقل هنا لواجهة الـ OTP
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}