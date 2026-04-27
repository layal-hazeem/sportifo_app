import 'dart:async'; // ضروري للمؤقت
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/features/auth/presentation/view/complete_profile_info.dart';
import 'package:sportifo_app/features/auth/presentation/view/reset_password_screen.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/view/home_page.dart';
import '../../data/models/login/verify_otp_request.dart';
import '../view_model/login/login_cubit.dart';
import '../view_model/login/login_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';

class OTPScreen extends StatefulWidget {
  final String loginEmail;
  final bool isFromForgotPassword;

  const OTPScreen({
    super.key,
    required this.loginEmail,
    this.isFromForgotPassword = false,
  });
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final pinController = TextEditingController();

  // متغيرات المؤقت
  Timer? _timer;
  int _start = 60;
  bool _isFinished = false;

  void startTimer() {
    setState(() {
      _isFinished = false;
      _start = 60;
    });
    _timer?.cancel(); // تأمين لعدم تكرار التايمر
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isFinished = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer(); // يبدأ العد التنازلي فور فتح الشاشة
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final defaultPinTheme = PinTheme(
      width: 60,
      height: 65,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state is OtpLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is OtpSuccess) {
            Navigator.pop(context);

            final token = state.response.data!.token;

            if (widget.isFromForgotPassword) {
              // 🔐 نروح ل reset password
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(
                    email: widget.loginEmail,
                    otpCode: pinController.text,
                  ),
                ),
              );
            } else {
              // ✅ login flow
              await getIt<LocalStorage>().saveToken(token);
              Navigator.pushReplacementNamed(context, AppRoutes.editProfile);
            }
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AuthHeader(
                  title: l10n.otpTitle,
                  subtitle: l10n.otpSubtitle,
                  isCentered: true,
                ),
                const SizedBox(height: 60),
                Pinput(
                  controller: pinController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                ),
                const SizedBox(height: 60),
                CustomAuthButton(
                  text: l10n.verify,
                  onPressed: _isFinished
                      ? null // إذا انتهى الوقت الزر بكون معطل
                      : () {
                          // تأكدي من استيراد الملفات الصحيحة في أعلى الشاشة
                          final otpValue = pinController.text;
                          if (otpValue.isNotEmpty) {
                            context.read<LoginCubit>().verifyOtp(
                              VerifyOtpRequestBody(
                                login: widget.loginEmail,
                                otp: otpValue,
                              ),
                            );
                          }
                        },
                ),
                const SizedBox(height: 20),
                // عرض العداد أو زر إعادة الإرسال
                _isFinished
                    ? TextButton(
                        onPressed: () {
                          // استدعاء دالة إعادة الإرسال
                          // context.read<LoginCubit>().emitLoginStates(LoginRequest(login: widget.loginEmail, password: ...));
                          startTimer();
                        },
                        child: Text(
                          l10n.resendCode,
                          style: const TextStyle(
                            color: AppColors.primaryBtn,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Text(
                        "Resend code in 00:${_start.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
