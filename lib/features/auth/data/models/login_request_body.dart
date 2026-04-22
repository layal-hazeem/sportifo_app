class LoginRequestBody {
  final String emailOrPhone;
  final String password;

  LoginRequestBody({required this.emailOrPhone, required this.password});

  Map<String, dynamic> toJson() => {
    'email_or_phone': emailOrPhone,
    'password': password,
  };
}