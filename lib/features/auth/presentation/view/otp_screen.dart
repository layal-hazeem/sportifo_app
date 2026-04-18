import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 65,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
          BoxShadow(color: Colors.black12, offset: Offset(3, 3), blurRadius: 5),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.textDark)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(l10n.otpTitle, style: const TextStyle(fontSize: AppSizes.titleFontSize, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(l10n.otpSubtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.hintText)),
              const SizedBox(height: 60),

              Pinput(
                length: 4,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: AppColors.primaryBtn, width: 1.5),
                  ),
                ),
                onCompleted: (pin) => print(pin),
              ),

              const SizedBox(height: 60),
              CustomAuthButton(
                text: l10n.verify,
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordScreen()));
                },
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: Text(
                  l10n.resendCode,
                  style: const TextStyle(color: AppColors.primaryBtn, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}