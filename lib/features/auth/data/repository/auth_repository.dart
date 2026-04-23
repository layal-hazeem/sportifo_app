import '../models/login/forgot_password_request_body.dart';
import '../models/login/login_response.dart';
import '../models/login/login_request.dart';
import '../models/login/reset_password_request.dart';


import '../models/login/verify_otp_request.dart';
import '../models/register/register_request_model.dart';
import '../models/register/register_response_model.dart';
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

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      // 1. نحول الموديل الذي جاء من الواجهة إلى FormData
      // نضع await لأن تحويل الصورة إلى ملف يأخذ أجزاء من الثانية
      final formData = await request.toFormData();
      final response = await _authWebService.register(formData);
      return RegisterResponseModel.fromJson(response.data);

    } catch (e) {
      // نرمي الخطأ لكي يلتقطه الـ Cubit ويظهره للمستخدم
      rethrow;
    }
  }
}