import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/login_request_body.dart';

class AuthWebService {
  final Dio dio;
  AuthWebService(this.dio);

  Future<Response> login(LoginRequestBody loginRequestBody) async {
    return await dio.post(ApiConstants.login, data: loginRequestBody.toJson());
  }

// أضيفي هنا دوال الـ OTP و Reset Password بنفس الطريقة
}