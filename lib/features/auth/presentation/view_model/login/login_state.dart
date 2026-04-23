import '../../../data/models/login/login_response.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

// ✅ نجاح + verified
class LoginSuccess extends LoginState {
  final LoginResponse response;
  LoginSuccess(this.response);
}

// ✅ لازم OTP
class LoginNeedsOtp extends LoginState {
  final String login;
  LoginNeedsOtp(this.login);
}

// ❌ خطأ
class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

// OTP Loading
class OtpLoading extends LoginState {}

// OTP Success
class OtpSuccess extends LoginState {
  final LoginResponse response;
  OtpSuccess(this.response);
}

// OTP Error
class OtpError extends LoginState {
  final String message;
  OtpError(this.message);
}