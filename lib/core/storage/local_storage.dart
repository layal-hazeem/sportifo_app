import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  static const String _tokenKey = "token";
  static const String _onboardingKey = "onboarding_seen";

  // حقن الـ SharedPreferences من خلال الـ Constructor
  LocalStorage(this._prefs);

  // ------------------ إدارة التوكن ------------------
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
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
}