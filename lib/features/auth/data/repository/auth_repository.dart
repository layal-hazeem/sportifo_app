import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_request_model.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_respons_model.dart';

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

  Future<ApiResult<RegisterResponseModel>> register(RegisterRequestModel request) async {
    try {
      final formData = await request.toFormData();
      final response = await _authWebService.register(formData);

      // 🔥 في حال النجاح نغلف الرد بـ Success
      return Success(RegisterResponseModel.fromJson(response.data));

    } catch (e) {
      // 🔥 في حال الفشل نمرر الخطأ للـ Handler ليصطاده ونغلفه بـ Failure
      return Failure(ApiErrorHandler.handle(e));
    }
  }
Future<ApiResult<CompleteProfileResponsModel>> completeProfile(
  CompleteProfileRequestModel body,
) async {
  try {
    final formData = await body.toFormData();
    final response = await _authWebService.completeProfile(formData);

    return Success(
      CompleteProfileResponsModel.fromJson(response.data),
    );
  } catch (e) {
    return Failure(ApiErrorHandler.handle(e));
  }
}
}