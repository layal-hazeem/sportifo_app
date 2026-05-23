import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snack_bar_utils.dart';
import '../../../../l10n/app_localizations.dart';
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

  Timer? _timer;
  int _start = 60;
  bool _isFinished = false;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _isFinished = false;
      _start = 60;
    });

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
        setState(() => _isFinished = true);
      } else {
        setState(() => _start--);
      }
    });
  }

  void _showLoading(BuildContext context) {
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBtn,
        ),
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  void _hideLoading(BuildContext context) {
    if (_isDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogShowing = false;
    }
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
        listenWhen: (previous, current) =>
        current is OtpLoading ||
            current is OtpSuccess ||
            current is OtpError,

        listener: (context, state) async {
          if (state is OtpLoading) {
            _showLoading(context);
          } else if (state is OtpError) {
            _hideLoading(context);
            AppSnackBar.show(context, message: state.message, type: SnackBarType.error);
          }
          else if (state is OtpSuccess) {
            _hideLoading(context);
            AppSnackBar.show(
              context,
              message: state.response.message.isNotEmpty
                  ? state.response.message
                  : l10n.verifiedOtp,
              type: SnackBarType.success,
            );
            await Future.delayed(const Duration(milliseconds: 500));
            if (widget.isFromForgotPassword) {
              if (state.response.resetToken != null) {
                await getIt<LocalStorage>().saveToken(state.response.resetToken!);
              }
              Navigator.pushNamed(
                context,
                AppRoutes.resetPasswordScreen,
                arguments: {
                  'email': widget.loginEmail,
                  'resetToken': state.response.resetToken,
                  'otpCode': pinController.text,
                },
              );
            } else {
              if (state.response.token != null) {
                await getIt<LocalStorage>().saveToken(state.response.token!);
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
              }
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
                  backgroundColor: _isFinished
                      ? Colors.grey.shade400
                      : AppColors.primaryBtn,

                  onPressed: _isFinished
                      ? null
                      : () {
                    final otpValue = pinController.text;
                    if (otpValue.length < 6) {
                      AppSnackBar.show(
                        context,
                        message: l10n.enterFullCode,
                        type: SnackBarType.error,
                      );
                      return;

                    }

                    context.read<LoginCubit>().verifyOtp(
                      VerifyOtpRequestBody(
                        login: widget.loginEmail,
                        otp: otpValue,
                      ),
                      contextType: widget.isFromForgotPassword
                          ? OtpContext.forgotPassword
                          : OtpContext.login,
                    );
                  },
                ),

                const SizedBox(height: 20),

                _isFinished
                    ? TextButton(
                  onPressed: () {
                    pinController.clear();
                    context.read<LoginCubit>().resendOtp(widget.loginEmail);
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
                  "${l10n.resendCodeIn} 00:${_start.toString().padLeft(2, '0')}",
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