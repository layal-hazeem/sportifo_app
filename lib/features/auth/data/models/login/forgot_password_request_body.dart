class ForgotPasswordRequestBody {
  final String login;

  ForgotPasswordRequestBody({required this.login});

  Map<String, dynamic> toJson() => {'login': login};
}