class ResetPasswordRequestBody {
  final String login;
  final String code;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestBody({
    required this.login,
    required this.code,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'login': login,
    'code': code,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}