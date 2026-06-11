
import '../../../data/models/target_model.dart';

sealed class TargetState {}

// الحالة الابتدائية
final class TargetInitial extends TargetState {}

// حالة التحميل أثناء طلب السيرفر
final class TargetLoading extends TargetState {}

// حالة النجاح وبنمرر معها الـ TargetModel المليان سعرات وماكروز للهوم
final class TargetSuccess extends TargetState {
  final TargetModel targetData;
  TargetSuccess(this.targetData);
}

// حالة الفشل العادية (مشكلة نت أو سيرفر)
final class TargetFailure extends TargetState {
  final String errorMessage;
  TargetFailure(this.errorMessage);
}

// 🔥 حالة الأمان الذكية: الباك-إند رجع رسالة خطأ تطلب إدخال الوزن أولاً
final class TargetWeightMissing extends TargetState {
  final String message;
  TargetWeightMissing(this.message);
}