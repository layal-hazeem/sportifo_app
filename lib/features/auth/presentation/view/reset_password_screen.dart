import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/login/reset_password_request.dart';
import '../view_model/login/login_cubit.dart';
import '../view_model/login/login_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordScreen({super.key, required this.email, required this.otpCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // نجحت العملية! ارجعي لأول صفحة (Login)
            Navigator.popUntil(context, (route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Success! Please login with new password")),
            );
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
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
                  AuthHeader(title: l10n.resetPasswordTitle, subtitle: null),
                  const SizedBox(height: 50),

                  Text(l10n.newPassword, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.labelFontSize)),
                  const SizedBox(height: 15),
                  CustomNeumorphicField(
                    controller: passwordController,
                    hint: l10n.passwordHint,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) => value!.length < 8 ? l10n.passwordTooShort : null,
                  ),

                  const SizedBox(height: 30),

                  Text(l10n.confirmPassword, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizes.labelFontSize)),
                  const SizedBox(height: 15),
                  CustomNeumorphicField(
                    controller: confirmPasswordController,
                    hint: l10n.passwordHint,
                    icon: Icons.lock_reset,
                    isPassword: true,
                    validator: (value) => value != passwordController.text ? "Passwords don't match" : null,
                  ),

                  const SizedBox(height: 60),
                  CustomAuthButton(
                    text: l10n.updatePassword,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<LoginCubit>().emitResetPasswordStates(
                          ResetPasswordRequestBody(
                            login: widget.email,
                            code: widget.otpCode,
                            password: passwordController.text,
                            passwordConfirmation: confirmPasswordController.text,
                          ),
                        );
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}