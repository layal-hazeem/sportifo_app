// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sportifo';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get emailOrPhone => 'Email or Phone Number';

  @override
  String get emailHint => 'Enter your email or phone number';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get login => 'Login';

  @override
  String get forgotPassword => 'Forgot password ?';

  @override
  String get forgotPasswordDesc => 'Enter your email to receive an OTP code';

  @override
  String get sendCode => 'Send Code';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get otpTitle => 'Verification';

  @override
  String get otpSubtitle => 'Please enter the 4-digit code sent to your email or phone number';

  @override
  String get verify => 'Verify';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get progress => 'Progress';

  @override
  String get myPlans => 'My Plans';

  @override
  String get home => 'Home';

  @override
  String get workouts => 'Workouts';

  @override
  String get settings => 'Settings';

  @override
  String get dontHaveAccount => 'Don\'t have an account ?';

  @override
  String get signUp => 'Sign up';
}
