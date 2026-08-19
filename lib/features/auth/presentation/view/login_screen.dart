//login screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/view/home_page.dart';
import '../../data/models/login/login_request.dart';
import '../view_model/login/login_cubit.dart';
import '../view_model/login/login_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_neumorphic_field.dart';

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
      backgroundColor: context.backgroundColor,
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
              final role = state.response.data!.user.role;
              print("Current Role = $role");

              // 🔥 حفظ التوكن
              await getIt<LocalStorage>().saveToken(token);
              await getIt<LocalStorage>().saveRole(role);
              await NotificationService().registerDeviceToBackend();
              AppSnackBar.show(
                context,
                message: l10n.loginSuccess,
                type: SnackBarType.success,
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }

            else if (state is LoginNeedsOtp) {
              Navigator.pop(context); // إغلاق الـ Loading Dialog

              Navigator.pushNamed(
                context,
                AppRoutes.otpScreen,
                arguments: state.login, // نرسل الإيميل كـ argument
              );
            }

            else if (state is LoginError) {
              Navigator.pop(context);

              AppSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
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
                          style: TextStyle(
                              fontSize: AppSizes.titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: context.textColor)),
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
                    // حقل كلمة السر في LoginScreen
                    CustomNeumorphicField(
                      controller: passwordController,
                      hint: l10n.passwordHint,
                      icon: Icons.lock_outline, // أيقونة القفل كأيقونة أساسية (Prefix)
                      isPassword: true,        // هذا سيفعل زر العين تلقائياً (Suffix)
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
                          // ✅ التعديل هنا: نستخدم pushNamed بدلاً من push العادي
                          Navigator.pushNamed(context, AppRoutes.forgotPasswordScreen);
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
                          style: TextStyle(color: context.textColor, fontSize: AppSizes.hintFontSize),
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