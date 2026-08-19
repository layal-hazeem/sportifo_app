import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  static const String _tokenKey = "token";
  static const String _onboardingKey = "onboarding_seen";
  static const String _roleKey = "role";

  // حقن الـ SharedPreferences من خلال الـ Constructor
  LocalStorage(this._prefs);

  // ------------------ إدارة التوكن ------------------
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }


static const String _userIdKey = "user_id";

Future<void> saveUserId(int id) async {
  await _prefs.setInt(_userIdKey, id);
}

int? getUserId() {
  return _prefs.getInt(_userIdKey);
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
}