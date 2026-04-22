import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/login/verify_otp_request.dart';
import '../../data/models/login/login_response.dart';
import '../view_model/login/login_cubit.dart';
import '../view_model/login/login_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import 'reset_password_screen.dart';

class OTPScreen extends StatefulWidget {
  // بنضيف هاد المتغير عشان نستقبل الإيميل من صفحة الـ Login
  final String loginEmail;

  const OTPScreen({super.key, required this.loginEmail});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // 1. تعريف الكنترولر اللي كان ناقصك
  final pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 65,
      textStyle: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5),
          BoxShadow(color: Colors.black12, offset: Offset(3, 3), blurRadius: 5),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textDark)),
      // 2. إضافة BlocListener لمراقبة نجاح عملية الـ OTP
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess<LoginResponse>) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(
                  email: widget.loginEmail, // نمرر الإيميل
                  otpCode: pinController.text, // نمرر الكود اللي كتبه المستخدم
                ),
              ),
            );
          }else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
            child: Column(
              children: [
                AuthHeader(
                  title: l10n.otpTitle,
                  subtitle: l10n.otpSubtitle,
                  isCentered: true,
                ),
                const SizedBox(height: 60),
                Pinput(
                  controller: pinController, // 3. ربط الكنترولر هون
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primaryBtn, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                CustomAuthButton(
                  text: l10n.verify,
                  onPressed: () {
                    // 4. استدعاء دالة التأكد من الـ OTP
                    context.read<LoginCubit>().verifyOtp(
                      VerifyOtpRequestBody(
                        login: widget.loginEmail, // الإيميل الممرر من الصفحة السابقة
                        otp: pinController.text, // الكود المكتوب
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // منطق إعادة الإرسال (اختياري حالياً)
                  },
                  child: Text(
                    l10n.resendCode,
                    style: const TextStyle(
                        color: AppColors.primaryBtn,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 5. تنظيف الذاكرة
    pinController.dispose();
    super.dispose();
  }
}