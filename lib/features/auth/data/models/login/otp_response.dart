import 'login_data.dart';

class OtpResponse {
  final String message;
  final String? token;
  final String? resetToken;
  final LoginData? user;

  OtpResponse({
    required this.message,
    this.token,
    this.resetToken,
    this.user,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    String? token;
    String? resetToken;
    LoginData? user;

    if (data is Map<String, dynamic>) {
      token = data['token']?.toString();
      resetToken = data['reset_token']?.toString();
      if (data['user'] is Map<String, dynamic>) {
        try {
          user = LoginData.fromJson(data['user']);
        } catch (e) {
          print("Error parsing user: $e");
        }
      }
    }

    return OtpResponse(
      message: json['message']?.toString() ?? '',
      token: token,
      resetToken: resetToken,
      user: user,
    );
  }
}