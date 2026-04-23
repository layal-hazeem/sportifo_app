import 'login_data.dart';

class LoginResponse {
  final String message;
  final LoginData? data;
  final bool isNotVerified;

  LoginResponse({
    required this.message,
    this.data,
    required this.isNotVerified,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    // 🟡 حالة not verified
    if (rawData is String && rawData.contains("not verified")) {
      return LoginResponse(
        message: json['message'].toString(),
        data: null,
        isNotVerified: true,
      );
    }

    // 🟢 حالة success
    if (rawData is Map) {
      return LoginResponse(
        message: json['message'].toString(),
        data: LoginData.fromJson(rawData as Map<String, dynamic>),
        isNotVerified: false,
      );
    }

    // 🔴 حالة error
    return LoginResponse(
      message: json['message'].toString(),
      data: null,
      isNotVerified: false,
    );
  }
}