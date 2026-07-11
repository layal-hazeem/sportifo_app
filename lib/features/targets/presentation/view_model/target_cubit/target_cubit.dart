import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/target_repository.dart';
import 'target_state.dart';

class TargetCubit extends Cubit<TargetState> {
  final TargetRepository _repository;

  TargetCubit(this._repository) : super(TargetInitial());

  Future<void> fetchLatestTarget() async {
    //  لا تظهري التحميل إلا إذا لم يكن لدينا داتا سابقة
    if (state is! TargetSuccess) {
      emit(TargetLoading());
    }

    final result = await _repository.getLatestTarget();

    if (isClosed) return; // حماية من الكراش

    switch (result) {
      case Success():
        emit(TargetSuccess(result.data));
        break;
      case Failure(message: final errorMsg):
      // 🔥 الحماية القصوى: إذا الخطأ سببه "لا يوجد إنترنت"
        if (errorMsg.contains("No Internet") || errorMsg.contains("Connection timeout")) {
          // 🔥 إذا كان هناك داتا مكيشة (Success)، لا تظهري رسالة فشل
          if (state is TargetSuccess) return;
        }
        if (result.message.contains("no targets") || result.message.contains("not found")) {
          emit(TargetInitial());
        } else {
          emit(TargetFailure(result.message));
        }
        break;
    }
  }

  Future<void> updateTargetGoal(String goal) async {
    emit(TargetLoading());

    final result = await _repository.setTarget(goal);

    if (isClosed) return;

    switch (result) {
      case Success():
        emit(TargetSuccess(result.data));
        break;
      case Failure():
        if (result.message.toLowerCase().contains("weight")) {
          emit(TargetWeightMissing(result.message));
        } else {
          emit(TargetFailure(result.message));
        }
        break;
    }
  }
}