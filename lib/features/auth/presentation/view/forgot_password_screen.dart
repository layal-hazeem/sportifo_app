import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_model/login/forgot_password_cubit.dart';
import '../view_model/login/login_cubit.dart'; // أو ForgotPasswordCubit
import '../view_model/login/login_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.textDark)),
      body: BlocListener<ForgotPasswordCubit, LoginState>( // تأكدي من نوع الـ Cubit المستخدم
        listener: (context, state) {
          if (state is LoginSuccess) {
            // عند النجاح ننتقل للـ OTP ونمرر الإيميل
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  loginEmail: emailController.text.trim(),
                  isFromForgotPassword: true,
                ),
              ),
            );
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthHeader(
                    title: l10n.forgotPassword,
                    subtitle: l10n.forgotPasswordDesc,
                  ),
                  const SizedBox(height: 50),
                  Text(l10n.emailOrPhone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.labelFontSize)),
                  const SizedBox(height: 15),
                  CustomNeumorphicField(
                    controller: emailController,
                    hint: l10n.emailHint,
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.fieldRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  CustomAuthButton(
                    text: l10n.sendCode,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // استدعاء دالة إرسال الكود
                        context.read<ForgotPasswordCubit>().emitForgotPasswordStates(emailController.text.trim());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}