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
    final data = json['data'] as Map<String, dynamic>?;

    return OtpResponse(
      message: json['message'] ?? '',
      token: data?['token'],
      resetToken: data?['reset_token'],
      user: data?['user'] != null ? LoginData.fromJson(data!['user']) : null,
    );
  }
}