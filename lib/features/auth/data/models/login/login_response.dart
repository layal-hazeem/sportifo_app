class LoginResponse {
  final int? message; // تحويل النوع من String إلى int
  final String? data;    // تغيير الاسم من token إلى data ليطابق السيرفر

  LoginResponse({this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    // لازم نستخدم نفس الكلمات المفتاحية (Keys) اللي بعتها الباك إيند
    message: json['message'] as int?,
    data: json['data'] as String?,
  );
}