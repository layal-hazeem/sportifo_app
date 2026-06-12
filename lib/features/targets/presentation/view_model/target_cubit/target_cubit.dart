import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/target_repository.dart';
import 'target_state.dart';

class TargetCubit extends Cubit<TargetState> {
  final TargetRepository _repository;

  TargetCubit(this._repository) : super(TargetInitial());

  // 1️⃣ دالة جلب السعرات والماكروز لشاشة الهوم (GET)
  Future<void> fetchLatestTarget() async {
    emit(TargetLoading());

    final result = await _repository.getLatestTarget();

    switch (result) {
      case Success():
        emit(TargetSuccess(result.data));
        break;
      case Failure():
      // إذا السيرفر فاضي لسه واليوزر ماله حاطط هدف، بنبعث Initial أو حالة مخصصة
        if (result.message.contains("no targets") || result.message.contains("not found")) {
          emit(TargetInitial()); // ليعرض كرت التفعيل الذكي بالهوم
        } else {
          emit(TargetFailure(result.message));
        }
        break;
    }
  }

  // 2️⃣ دالة حفظ أو تعديل الهدف (POST)
  Future<void> updateTargetGoal(String goal) async {
    emit(TargetLoading());

    final result = await _repository.setTarget(goal);

    switch (result) {
      case Success():
        emit(TargetSuccess(result.data)); // تحديث فوري وسلس للـ UI
        break;
      case Failure():
      // ⚡ الفحص الذكي: لو رسالة الخطأ من السيرفر بتقول لازم إدخال وزن
        if (result.message.toLowerCase().contains("weight")) {
          emit(TargetWeightMissing(result.message));
        } else {
          emit(TargetFailure(result.message));
        }
        break;
    }
  }
}