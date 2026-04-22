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
      emit(LoginSuccess(response));
    } catch (error) {
      // التقاط أي خطأ من Dio أو السيرفر
      emit(LoginError(error: error.toString()));
    }
  }
  void verifyOtp(VerifyOtpRequestBody body) async {
    emit(LoginLoading());
    try {
      final response = await _authRepository.verifyOtp(body);
      emit(LoginSuccess<LoginResponse>(response)); // حددنا النوع هون
    } catch (error) {
      emit(LoginError(error: error.toString()));
    }
  }

  // دالة نسيان كلمة السر
// داخل ForgotPasswordCubit
  void emitForgotPasswordStates(String email) async {
    emit(LoginLoading());
    try {
      final response = await _authRepository.forgotPassword(
          ForgotPasswordRequestBody(login: email)
      );
      // حددي نوع البيانات المرجعة (LoginResponse)
      emit(LoginSuccess<LoginResponse>(response));
    } catch (error) {
      emit(LoginError(error: error.toString()));
    }
  }

  void emitResetPasswordStates(ResetPasswordRequestBody body) async {
    emit(LoginLoading());
    try {
      final response = await _authRepository.resetPassword(body);
      emit(LoginSuccess<LoginResponse>(response));
    } catch (error) {
      emit(LoginError(error: error.toString()));
    }
  }
}