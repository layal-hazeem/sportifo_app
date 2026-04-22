import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/login/login_request.dart';
import '../models/register/register_request_model.dart';

class AuthWebService {
  final Dio dio;
  AuthWebService(this.dio);

  Future<Response> login(LoginRequestBody loginRequestBody) async {
    return await dio.post(ApiConstants.login, data: loginRequestBody.toJson());
  }

// أضيفي هنا دوال الـ OTP و Reset Password بنفس الطريقة

  Future<Response> register(FormData formData) async {
    return await dio.post(ApiConstants.register, data: formData);
  }
}