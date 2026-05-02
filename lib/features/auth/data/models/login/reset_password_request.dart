class ResetPasswordRequestBody {
  final String email; // أضيفي هذا
  final String code;  // وهذا (أو token حسب الـ API)
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestBody({
    required this.email,
    required this.code,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'login': email, // تأكدي من المسمى المطلوب من الباك إند (email أو login)
    'code': code,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}