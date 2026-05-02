import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/models/login/forgot_password_request_body.dart';
import '../../../data/models/login/login_request.dart';
import '../../../data/models/login/login_response.dart';
import '../../../data/models/login/reset_password_request.dart';
import '../../../data/models/login/verify_otp_request.dart';
import '../../../data/repository/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(LoginInitial());

  // دالة تسجيل الدخول
  void emitLoginStates(LoginRequest loginRequestBody) async {
    emit(LoginLoading());

    final result = await _authRepository.login(loginRequestBody);

    if (result is Success<LoginResponse>) {
      final response = result.data;

      // الحالة الخاصة بـ Sportifo: الحساب غير مفعل
      if (response.isNotVerified) {
        emit(LoginNeedsOtp(loginRequestBody.login));
      } else {
        emit(LoginSuccess(response));
      }
    } else if (result is Failure<LoginResponse>) {
      emit(LoginError(result.message));
    }
  }

  // دالة التحقق من الـ OTP
  void verifyOtp(VerifyOtpRequestBody body) async {
    emit(OtpLoading());

    final result = await _authRepository.verifyOtp(body);

    if (result is Success<LoginResponse>) {
      emit(OtpSuccess(result.data));
    } else if (result is Failure<LoginResponse>) {
      // هنا ستصل رسالة "Invalid or expired OTP" تلقائياً للسناك بار
      emit(OtpError(result.message));
    }
  }

  // دالة إعادة تعيين كلمة السر
  void emitResetPasswordStates(ResetPasswordRequestBody body) async {
    emit(LoginLoading());

    final result = await _authRepository.resetPassword(body);

    if (result is Success<LoginResponse>) {
      emit(LoginSuccess(result.data));
    } else if (result is Failure<LoginResponse>) {
      emit(LoginError(result.message));
    }
  }

  // دالة إعادة إرسال الكود
  void resendOtp(String email) async {
    emit(ResendOtpLoading());

    final result = await _authRepository.resendOtp(email);

    if (result is Success<LoginResponse>) {
      emit(ResendOtpSuccess(result.data.message ?? "Code resent"));
    } else if (result is Failure<LoginResponse>) {
      emit(ResendOtpError(result.message));
    }
  }
}