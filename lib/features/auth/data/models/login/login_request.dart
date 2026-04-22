class LoginRequest {
  final String login; // غيرنا الاسم ليتطابق مع طلب الباك إيند (إيميل أو هاتف)
  final String password;

  LoginRequest({required this.login, required this.password});

  Map<String, dynamic> toJson() => {
    'login': login, // هاد أهم سطر! لازم يكون "login" مثل صورة البوتمان تماماً
    'password': password,
  };
}