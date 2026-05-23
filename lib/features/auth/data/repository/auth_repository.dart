import 'package:dio/dio.dart';
import 'dart:convert';

import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_request_model.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_respons_model.dart';

import '../models/login/forgot_password_request_body.dart';
import '../models/login/login_response.dart';
import '../models/login/login_request.dart';
import '../models/login/otp_response.dart';
import '../models/login/reset_password_request.dart';


import '../models/login/verify_otp_request.dart';
import '../models/register/register_request_model.dart';
import '../models/register/register_response_model.dart';
import '../web_services/auth_webService.dart';

class AuthRepository {
  final AuthWebService _authWebService;
  AuthRepository(this._authWebService);

  Future<ApiResult<LoginResponse>> login(LoginRequest loginRequestBody) async {
    try {
      final response = await _authWebService.login(loginRequestBody);
      return Success(LoginResponse.fromJson(response.data));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
  Future<ApiResult<OtpResponse>> verifyOtp(
      VerifyOtpRequestBody verifyOtpRequestBody, {
        bool isReset = false,
      }) async {
    try {
      final response = await _authWebService.verifyOtp(verifyOtpRequestBody, isReset: isReset);

      Map<String, dynamic> jsonMap;
      if (response.data is Map<String, dynamic>) {
        jsonMap = response.data;
      } else if (response.data is String) {
        jsonMap = jsonDecode(response.data);
      } else {
        return Failure("Unexpected response format from server");
      }


      final otpResponse = OtpResponse.fromJson(jsonMap);
      return Success(otpResponse);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<LoginResponse>> forgotPassword(ForgotPasswordRequestBody body) async {
    try {
      final response = await _authWebService.forgotPassword(body);
      return Success(LoginResponse.fromJson(response.data));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<LoginResponse>> resetPassword(ResetPasswordRequestBody body) async {
    try {
      final response = await _authWebService.resetPassword(body);
      return Success(LoginResponse.fromJson(response.data));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<LoginResponse>> resendOtp(String login) async {
    try {
      final response = await _authWebService.resendOtp(login);
      return Success(LoginResponse.fromJson(response.data));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<RegisterResponseModel>> register(RegisterRequestModel request) async {
    try {
      final formData = await request.toFormData();
      final response = await _authWebService.register(formData);

      return Success(RegisterResponseModel.fromJson(response.data));

    } on DioException catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    } catch (e) {
      return Failure("Unexpected error occurred");
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

Future<ApiResult<void>> logout() async {
  try {
    await _authWebService.logout();
    return  Success(null);
  } catch (e) {
    return Failure(ApiErrorHandler.handle(e));
  }
}

}