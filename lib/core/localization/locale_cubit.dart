import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/local_storage.dart'; // تأكدي من مسار الـ LocalStorage

class LocaleCubit extends Cubit<Locale> {
  final LocalStorage _localStorage;

  // عند تشغيل التطبيق، نجلب اللغة المحفوظة في الكاش (وإذا لم توجد نعتبرها إنجليزي 'en')
  LocaleCubit(this._localStorage) : super(Locale(_localStorage.getLanguage()));

  // دالة لتغيير اللغة
  void changeLanguage(String languageCode) async {
    // 1. نحفظ اللغة الجديدة في الكاش
    await _localStorage.setLanguage(languageCode);

    // 2. نطلق الحالة الجديدة ليتم تحديث واجهات التطبيق فوراً
    emit(Locale(languageCode));
  }
}