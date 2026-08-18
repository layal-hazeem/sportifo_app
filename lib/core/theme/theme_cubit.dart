import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeBoxName = 'settings_box';
  static const String _themeKey = 'is_dark_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    try {
      var box = Hive.box(_themeBoxName);
      bool isDark = box.get(_themeKey, defaultValue: false);
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      emit(ThemeMode.light);
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    try {
      var box = Hive.box(_themeBoxName);
      await box.put(_themeKey, isDark);
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      // التعامل مع الخطأ
    }
  }
}