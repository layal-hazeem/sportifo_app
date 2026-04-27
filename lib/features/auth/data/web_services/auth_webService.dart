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
import '../models/register/register_request_model.dart';

class AuthWebService {
  final Dio dio;
  AuthWebService(this.dio);

  Future<Response> login(LoginRequest loginRequest) async {
    return await dio.post(ApiConstants.login, data: loginRequest.toJson());
  }
  Future<Response> verifyOtp(VerifyOtpRequestBody verifyOtpRequestBody) async {
    return await dio.post(ApiConstants.verifyOtp, data: verifyOtpRequestBody.toJson());
  }

// في ملف auth_web_service.dart
  Future<Response> forgotPassword(ForgotPasswordRequestBody body) async {
    return await dio.post(
      ApiConstants.forgotPassword,
      data: body.toJson(), // هون منبعت البيانات بصيغة Map
    );
  }

  Future<Response> resetPassword(ResetPasswordRequestBody body) async {
    return await dio.post(ApiConstants.resetPassword, data: body.toJson());
// أضيفي هنا دوال الـ OTP و Reset Password بنفس الطريقة


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
}