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
  void verifyOtp(VerifyOtpRequestBody body) async {
    emit(OtpLoading());

    try {
      final response = await _authRepository.verifyOtp(body);

      // ✅ نجاح (في token)
      if (response.data != null) {
        emit(OtpSuccess(response));
      }
      // ❌ خطأ (OTP غلط أو منتهي)
      else {
        emit(OtpError(response.message));
      }

    } catch (error) {
      emit(OtpError("Invalid or expired OTP"));
    }
  }

  // دالة نسيان كلمة السر
// داخل ForgotPasswordCubit
//   void emitForgotPasswordStates(String email) async {
//     emit(LoginLoading());
//     try {
//       final response = await _authRepository.forgotPassword(
//           ForgotPasswordRequestBody(login: email)
//       );
//       emit(LoginSuccess<LoginResponse>(response));
//     } catch (error) {
//       emit(LoginError(error: error.toString()));
//     }
//   }

  void emitResetPasswordStates(ResetPasswordRequestBody body) async {
    emit(LoginLoading());

    try {
      final response = await _authRepository.resetPassword(body);

      // ✅ نجاح (data null طبيعي)
      if (response.message.contains("successfully")) {
        emit(LoginSuccess(response));
      } else {
        emit(LoginError(response.message));
      }

    } catch (error) {
      emit(LoginError("Something went wrong"));
    }
  }

}