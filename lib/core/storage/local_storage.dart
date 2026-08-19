import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  static const String _tokenKey = "token";
  static const String _onboardingKey = "onboarding_seen";
  static const String _roleKey = "role";
  static const String _userIdKey = "user_id";

  // حقن الـ SharedPreferences من خلال الـ Constructor
  LocalStorage(this._prefs);

  // ------------------ إدارة التوكن ------------------
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

 // ✅ جلب User ID
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  // ✅ حفظ User ID
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  // ------------------ إدارة الأون بوردينغ ------------------
  Future<void> saveOnboardingSeen() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  bool isOnboardingSeen() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }
  Future<void> setLanguage(String lang) async {
    await _prefs.setString('lang', lang);
  }

  String getLanguage() {
    return _prefs.getString('lang') ?? 'en';
  }

  //-------------role-----------------
  Future<void> saveRole(String role) async {
  await _prefs.setString(_roleKey, role);
}

String? getRole() {
  return _prefs.getString(_roleKey);
}

Future<void> clearRole() async {
  await _prefs.remove(_roleKey);
}


// أضفي هذه الدالة داخل كلاس LocalStorage

Future<void> clearUserSession() async {
  await _prefs.remove(_tokenKey);
  await _prefs.remove(_roleKey);
  await _prefs.remove(_userIdKey);
  // ملاحظة: احتفظي بـ onboarding_seen و lang حتى لا تتأثر إعدادات التطبيق العامة
}
}