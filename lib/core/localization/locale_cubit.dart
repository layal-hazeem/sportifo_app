import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/notification_service.dart';
import '../storage/local_storage.dart';
import '../network/dio_factory.dart'; // 🔥 1. ضيفي هذا الاستيراد ضروري جداً

class LocaleCubit extends Cubit<Locale> {
  final LocalStorage _localStorage;

  LocaleCubit(this._localStorage) : super(Locale(_localStorage.getLanguage()));

  void changeLanguage(String languageCode) async {
    // 1. نحفظ اللغة الجديدة في الكاش
    await _localStorage.setLanguage(languageCode);

    // 🔥 2. السحر هنا: مسح كاش الـ Dio فوراً لتجبر كل الشاشات على جلب داتا جديدة باللغة الجديدة!
    await DioFactory.clearCache();

    // 3. نطلق الحالة الجديدة ليتم تحديث واجهات التطبيق فوراً
    emit(Locale(languageCode));
    await NotificationService().registerDeviceToBackend();
  }
}