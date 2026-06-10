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
    final message = json['message']?.toString() ?? '';

    // 1. حالة الـ Not Verified (فحص الرسالة أو الـ data)
    if (message.toLowerCase().contains("not verified") ||
        (rawData is String && rawData.contains("not verified"))) {
      return LoginResponse(message: message, data: null, isNotVerified: true);
    }

    // 2. حالة النجاح مع وجود بيانات (Login)
    if (rawData is Map<String, dynamic>) {
      return LoginResponse(
        message: message,
        data: LoginData.fromJson(rawData),
        isNotVerified: false,
      );
    }

    // 3. حالة النجاح بدون بيانات (Reset Password / Message Only)
    // هنا الحل: نعتبر النجاح إذا لم يكن هناك خطأ صريح من السيرفر
    return LoginResponse(message: message, data: null, isNotVerified: false);
  }
}
