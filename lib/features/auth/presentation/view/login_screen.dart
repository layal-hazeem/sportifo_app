import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                Center(
                  child: Text(
                    l10n.welcomeBack,
                    style: const TextStyle(
                        fontSize: AppSizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                Text(l10n.emailOrPhone, style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.labelFontSize,
                )),
                const SizedBox(height: 15),
                CustomNeumorphicField(
                    hint: l10n.emailHint,
                    icon: Icons.email_outlined
                ),

                const SizedBox(height: 35),

                Text(l10n.password,  style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.labelFontSize,
                )),
                const SizedBox(height: 15),
                CustomNeumorphicField(
                  hint: l10n.passwordHint,
                  icon: Icons.visibility_off_outlined,
                  isPassword: true,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                        l10n.forgotPassword,
                        style: const TextStyle(color: AppColors.linkColor, fontSize: AppSizes.mediumFontSize)
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                CustomAuthButton(
                  text: l10n.login,
                  onPressed: () {
                    // هي لاحقاً مشان اربط الواجهة مع ال view model اللي هيي ال bloc
                  },
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: const TextStyle(color: AppColors.textDark, fontSize: AppSizes.hintFontSize),
                    ),
                    TextButton(
                      onPressed: () {
                        //  Sign Up لاحقاً
                      },
                      child: Text(
                        l10n.signUp,
                        style: const TextStyle(
                          color: AppColors.primaryBtn,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.mediumFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}