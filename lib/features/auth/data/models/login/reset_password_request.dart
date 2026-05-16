class ResetPasswordRequestBody {
  final String email;
  final String code;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestBody({
    required this.email,
    required this.code,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'login': email,
    'code': code,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}