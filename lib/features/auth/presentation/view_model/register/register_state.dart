import 'package:flutter/material.dart';

@immutable
sealed class RegisterState {}

// 1. حالة البداية (الشكل الافتراضي للواجهة)
final class RegisterInitial extends RegisterState {}

// 2. حالة التحميل (عندما يضغط المستخدم على زر التسجيل وننتظر الـ API)
final class RegisterLoading extends RegisterState {}

// 3. حالة النجاح (تم إنشاء الحساب بنجاح)
final class RegisterSuccess extends RegisterState {}

// 4. حالة الفشل (في حال انقطاع النت أو إيميل مستخدم مسبقاً)
final class RegisterFailure extends RegisterState {
  final String errorMessage;

  RegisterFailure({required this.errorMessage});
}