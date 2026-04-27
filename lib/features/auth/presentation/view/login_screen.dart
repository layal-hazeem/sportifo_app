import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/view/home_page.dart';
import '../../data/models/login/login_request.dart';
import '../view_model/login/login_cubit.dart';
import '../view_model/login/login_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';
import 'forgot_password_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      // 2. استخدام BlocListener لمراقبة الحالة وتغيير الشاشات
      body: BlocListener<LoginCubit, LoginState>(
        // ... بداخل الـ BlocListener في LoginScreen
          listener: (context, state) async {
            if (state is LoginLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
            }

            else if (state is LoginSuccess) {
              Navigator.pop(context);

              final token = state.response.data!.token;

              // 🔥 حفظ التوكن
              await getIt<LocalStorage>().saveToken(token);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Login Successful!"),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }

            else if (state is LoginNeedsOtp) {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OTPScreen(loginEmail: state.login),
                ),
              );
            }

            else if (state is LoginError) {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        child: SafeArea(
          child: SizedBox.expand(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.mainPadding),
              child: Form(
                key: formKey, // 3. ربط الفورم
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Text(l10n.welcomeBack,
                          style: const TextStyle(
                              fontSize: AppSizes.titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                    ),
                    const SizedBox(height: 80),
                    Text(l10n.emailOrPhone,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.labelFontSize)),
                    const SizedBox(height: 15),
                    CustomNeumorphicField(
                      controller: loginController,
                      hint: l10n.emailHint,
                      icon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return l10n.fieldRequired;
                        return null;
                      },
                    ),
                    const SizedBox(height: 35),
                    Text(l10n.password,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.labelFontSize)),
                    const SizedBox(height: 15),
                    CustomNeumorphicField(
                      controller: passwordController,
                      hint: l10n.passwordHint,
                      icon: Icons.visibility_off_outlined,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return l10n.fieldRequired;
                        if (value.length < 8) return l10n.passwordTooShort;
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                        },
                        child: Text(l10n.forgotPassword,
                            style: const TextStyle(color: AppColors.linkColor, fontSize: AppSizes.mediumFontSize)),
                      ),
                    ),
                    const SizedBox(height: 35),
                    CustomAuthButton(
                      text: l10n.login,
                      onPressed: () {
                        // 4. تنفيذ الـ Validation قبل الإرسال
                        if (formKey.currentState!.validate()) {
                          context.read<LoginCubit>().emitLoginStates(
                            LoginRequest(
                              login: loginController.text.trim(),
                              password: passwordController.text,
                            ),
                          );
                        }
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
                          onPressed: register,
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
                    ),                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void register() {
    Navigator.pushReplacementNamed(context, AppRoutes.register);
  }
  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}