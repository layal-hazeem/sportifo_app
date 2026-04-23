class ResetPasswordRequestBody {
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestBody({
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}