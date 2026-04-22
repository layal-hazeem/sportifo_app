import '../models/login/login_response.dart';
import '../models/login/login_request.dart';
import '../web_services/AuthWebService.dart';

class AuthRepository {
  final AuthWebService _authWebService;
  AuthRepository(this._authWebService);

  Future<AuthResponse> login(LoginRequestBody loginRequestBody) async {
    final response = await _authWebService.login(loginRequestBody);
    return AuthResponse.fromJson(response.data);
  }
}