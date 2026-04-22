import '../models/login/login_response.dart';
import '../models/login/login_request.dart';
import '../models/register/register_request_model.dart';
import '../models/register/register_response_model.dart';
import '../web_services/auth_webService.dart';

class AuthRepository {
  final AuthWebService _authWebService;
  AuthRepository(this._authWebService);

  Future<AuthResponse> login(LoginRequestBody loginRequestBody) async {
    final response = await _authWebService.login(loginRequestBody);
    return AuthResponse.fromJson(response.data);
  }

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      // 1. نحول الموديل الذي جاء من الواجهة إلى FormData
      // نضع await لأن تحويل الصورة إلى ملف يأخذ أجزاء من الثانية
      final formData = await request.toFormData();

      // 2. نرسل الـ FormData الجاهزة إلى الـ WebService
      final response = await _authWebService.register(formData);

      // 3. نحول الرد القادم من السيرفر (JSON) إلى الموديل الخاص بنا
      return RegisterResponseModel.fromJson(response.data);

    } catch (e) {
      // نرمي الخطأ لكي يلتقطه الـ Cubit ويظهره للمستخدم
      rethrow;
    }
  }
}