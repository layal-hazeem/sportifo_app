import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/login/forgot_password_request_body.dart';
import '../../../data/models/login/login_request.dart';
import '../../../data/models/login/login_response.dart';
import '../../../data/models/login/reset_password_request.dart';
import '../../../data/models/login/verify_otp_request.dart';
import '../../../data/repository/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  // نمرر الـ Repository عبر الـ Constructor (Dependency Injection)
  LoginCubit(this._authRepository) : super(LoginInitial());

  // الدالة التي ستستدعيها الواجهة عند الضغط على زر Login
  void emitLoginStates(LoginRequest loginRequestBody) async {
    emit(LoginLoading());

    try {
      final response = await _authRepository.login(loginRequestBody);
      print("🔥 RESPONSE MESSAGE: ${response.message}");
      print("🔥 RESPONSE DATA: ${response.data}");
      print("🔥 IS NOT VERIFIED: ${response.isNotVerified}");
      // 🟡 not verified
      if (response.isNotVerified) {
        emit(LoginNeedsOtp(loginRequestBody.login));
      }

      // 🟢 success
      else if (response.data != null) {
        emit(LoginSuccess(response));
      }

      // 🔴 error (مثل Invalid Credentials)
      else {
        emit(LoginError(response.message));
      }

    } catch (error) {
      emit(LoginError("Something went wrong"));
    }
  }
// في ملف login_cubit.dart
// في ملف login_cubit.dart
  void verifyOtp(VerifyOtpRequestBody body) async {
    emit(OtpLoading());
    try {
      final response = await _authRepository.verifyOtp(body);

      // التحقق الصارم من وجود التوكن كدليل نجاح
      if (response.data?.token != null && response.data!.token!.isNotEmpty) {
        emit(OtpSuccess(response));
      } else {
        emit(OtpError(response.message ?? "Invalid OTP"));
      }
    } catch (error) {
      // هنا سيتم استلام رسالة "Invalid or expired OTP" القادمة من السيرفر
      emit(OtpError(error.toString()));
    }
  }

  void emitResetPasswordStates(ResetPasswordRequestBody body) async {
    emit(LoginLoading());

    try {
      final response = await _authRepository.resetPassword(body);

      // التحقق من النجاح بناءً على الرسالة القادمة من البوست مان
      if (response.message.contains("successfully")) {
        emit(LoginSuccess(response));
      } else {
        // في حال رجع رسالة خطأ من السيرفر
        emit(LoginError(response.message));
      }
    } catch (error) {
      // التقاط أخطاء الـ 401 أو 422 وغيرها
      emit(LoginError("Failed to reset password. Please check your data."));
    }
  }

  // بداخل كلاس LoginCubit
  void resendOtp(String email) async {
    emit(ResendOtpLoading()); // حالة التحميل الخاصة بإعادة الإرسال

    try {
      final response = await _authRepository.resendOtp(email);
      emit(ResendOtpSuccess(response.message));
    } catch (error) {
      // error هنا ستكون النص الراجع من ApiErrorHandler
      emit(ResendOtpError(error.toString()));
    }
  }
}