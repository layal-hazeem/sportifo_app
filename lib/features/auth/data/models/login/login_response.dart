class AuthResponse {
  final int? message; // تحويل النوع من String إلى int
  final String? data;    // تغيير الاسم من token إلى data ليطابق السيرفر

  AuthResponse({this.message, this.data});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    // لازم نستخدم نفس الكلمات المفتاحية (Keys) اللي بعتها الباك إيند
    message: json['message'] as int?,
    data: json['data'] as String?,
  );
}