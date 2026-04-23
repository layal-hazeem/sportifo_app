class VerifyOtpRequestBody {
  final String login;
  final String otp;

  VerifyOtpRequestBody({required this.login, required this.otp});

  Map<String, dynamic> toJson() => {
    'login': login,
    'otp': int.tryParse(otp) ?? 0, // أضمن بكتير من parse العادية
  };
}