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
}
