import 'package:dio/dio.dart';
import 'package:sportifo_app/core/network/api_error_handler.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_request_model.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_respons_model.dart';
import '../../../../core/network/api_constants.dart';
import '../models/login/forgot_password_request_body.dart';
import '../models/login/login_request.dart';
import '../models/login/reset_password_request.dart';
import '../models/login/verify_otp_request.dart';

class AuthWebService {
  final Dio dio;
  AuthWebService(this.dio);

  Future<Response> login(LoginRequest loginRequest) async {
    return await dio.post(ApiConstants.login, data: loginRequest.toJson());
  }
  Future<Response> verifyOtp(VerifyOtpRequestBody verifyOtpRequestBody, {bool isReset = false}) async {
    final url = isReset ? ApiConstants.verifyResetOtp : ApiConstants.verifyOtp;

    return await dio.post(url, data: verifyOtpRequestBody.toJson());
  }

  Future<Response> forgotPassword(ForgotPasswordRequestBody body) async {
    return await dio.post(
      ApiConstants.forgotPassword,
      data: body.toJson(),
    );
  }

  Future<Response> resetPassword(ResetPasswordRequestBody body) async {
    FormData formData = FormData.fromMap(body.toJson());

    return await dio.post(
      ApiConstants.resetPassword,
      data: formData,
    );
  }
  Future<Response> resendOtp(String login) async {
    return await dio.post(
      ApiConstants.resendOtp,
      data: {'login': login},
    );
  }

  Future<Response> register(FormData formData) async {
    return await dio.post(ApiConstants.register, data: formData);
  }

  Future<Response> completeProfile(FormData formData) async {
    return await dio.post(
      ApiConstants.editProfile,
      data: formData,
    );
  }

  Future<Response> logout() async {
  return await dio.post(ApiConstants.logout);
}

}