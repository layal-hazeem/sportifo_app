import '../models/login/forgot_password_request_body.dart';
import '../models/login/login_response.dart';
import '../models/login/login_request.dart';
import '../models/login/reset_password_request.dart';
import '../models/login/verify_otp_request.dart';
import '../web_services/auth_webService.dart';

class AuthRepository {
  final AuthWebService _authWebService;
  AuthRepository(this._authWebService);

  Future<LoginResponse> login(LoginRequest loginRequestBody) async {
    final response = await _authWebService.login(loginRequestBody);
    // نمرر الـ response.data (التي هي Map) للـ Factory
    return LoginResponse.fromJson(response.data);
  }

  Future<LoginResponse> verifyOtp(VerifyOtpRequestBody verifyOtpRequestBody) async {
    final response = await _authWebService.verifyOtp(verifyOtpRequestBody);
    return LoginResponse.fromJson(response.data);
  }

// في ملف auth_repository.dart
  Future<LoginResponse> forgotPassword(ForgotPasswordRequestBody body) async {
    final response = await _authWebService.forgotPassword(body);
    return LoginResponse.fromJson(response.data);
  }

  Future<LoginResponse> resetPassword(ResetPasswordRequestBody body) async {
    final response = await _authWebService.resetPassword(body);
    return LoginResponse.fromJson(response.data);
  }
}