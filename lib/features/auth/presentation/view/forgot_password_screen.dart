import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/helpers/snack_bar_utils.dart'; // تأكدي من استيراد ملف السناك بار الخاص بكِ
import '../../../../l10n/app_localizations.dart';
import '../view_model/login/forgot_password_cubit.dart';
import '../view_model/login/login_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';

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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textColor),
      ),
      body: BlocListener<ForgotPasswordCubit, LoginState>(
        listener: (context, state) {
          if (state is ForgotPasswordOtpSuccess) {
            AppSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.success,
            );

            Navigator.pushNamed(
              context,
              AppRoutes.otpScreen,
              arguments: {
                'email': emailController.text.trim(),
                'isFromForgotPassword': true,
              },
            );
          } else if (state is ForgotPasswordOtpError) {
            AppSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  Text(
                    l10n.emailOrPhone,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomNeumorphicField(
                    controller: emailController,
                    hint: l10n.emailHint,
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return l10n.fieldRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  BlocBuilder<ForgotPasswordCubit, LoginState>(
                    builder: (context, state) {
                      return CustomAuthButton(
                        text: l10n.sendCode,
                        isLoading: state is LoginLoading,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context
                                .read<ForgotPasswordCubit>()
                                .emitForgotPasswordStates(
                                  emailController.text.trim(),
                                );
                          }
                        },
                      );
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
