// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سبورتيفو';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني أو رقم الهاتف';

  @override
  String get password => 'كلمة السر';

  @override
  String get passwordHint => 'أدخل كلمة السر';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get forgotPassword => 'نسيت كلمة السر؟';

  @override
  String get forgotPasswordDesc => 'أدخل بريدك الإلكتروني أو رقم الهاتف لاستلام رمز التحقق';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get otpTitle => 'التحقق من الرمز';

  @override
  String get otpSubtitle => 'يرجى إدخال الرمز المكون من 4 أرقام والمرسل إلى بريدك الإلكتروني أو رقم هاتفك';

  @override
  String get verify => 'تأكيد';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة السر';

  @override
  String get newPassword => 'كلمة السر الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة السر';

  @override
  String get updatePassword => 'تحديث كلمة السر';

  @override
  String get progress => 'تقدم';

  @override
  String get myPlans => 'خططي';

  @override
  String get home => ' الرئيسية';

  @override
  String get workouts => 'التمارين ';

  @override
  String get settings => 'الإعدادات';

  @override
  String get dontHaveAccount => 'ليس لديك حساب ؟';

  @override
  String get signUp => 'إنشاء حساب';
}
