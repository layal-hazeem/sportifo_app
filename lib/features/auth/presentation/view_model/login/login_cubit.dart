import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';      // 🔥 أضف هذا الاستيراد
import 'package:sportifo_app/core/storage/local_storage.dart';    // 🔥 أضف هذا الاستيراد
import '../../../../../core/network/api_result.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../data/models/login/login_request.dart';
import '../../../data/models/login/login_response.dart';
import '../../../data/models/login/otp_response.dart';
import '../../../data/models/login/reset_password_request.dart';
import '../../../data/models/login/verify_otp_request.dart';
import '../../../data/repository/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(LoginInitial());

  Future<void> emitLoginStates(LoginRequest loginRequestBody) async {
    emit(LoginLoading());

    final result = await _authRepository.login(loginRequestBody);

    if (result is Success<LoginResponse>) {
      final response = result.data;


      try {
        final user = response.data?.user;
        if (user != null) {
          await getIt<LocalStorage>().saveUserId(user.id);
          await getIt<LocalStorage>().saveRole(user.role);
        }
      } catch (e) {
        print(' فشل حفظ بيانات المستخدم: $e');
      }

      if (response.isNotVerified) {
        emit(LoginNeedsOtp(loginRequestBody.login));
      } else {

        emit(LoginSuccess(response));
      }
    } else if (result is Failure<LoginResponse>) {
      emit(LoginError(result.message));
    }
  }

  void verifyOtp(VerifyOtpRequestBody body, {required OtpContext contextType}) async {
    emit(OtpLoading());

    final isReset = (contextType == OtpContext.forgotPassword);

    final result = await _authRepository.verifyOtp(body, isReset: isReset);

    if (result is Success<OtpResponse>) {
      emit(OtpSuccess(result.data, contextType));
    } else {
      emit(OtpError((result as Failure).message));
    }
  }

  void emitResetPasswordStates(ResetPasswordRequestBody body) async {
    emit(ResetPasswordLoading());

    final result = await _authRepository.resetPassword(body);

    if (result is Success<LoginResponse>) {
      emit(LoginSuccess(result.data));
    } else if (result is Failure<LoginResponse>) {
      emit(LoginError(result.message));
    }
  }

  void resendOtp(String email) async {
    emit(ResendOtpLoading());

    final result = await _authRepository.resendOtp(email);

    if (result is Success<LoginResponse>) {
      emit(ResendOtpSuccess(result.data.message));
    } else if (result is Failure<LoginResponse>) {
      emit(ResendOtpError(result.message));
    }
  }
}