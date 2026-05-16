class VerifyOtpRequestBody {
  final String login;
  final String otp;

  VerifyOtpRequestBody({required this.login, required this.otp});

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'otp': int.parse(otp),
    };
  }
}