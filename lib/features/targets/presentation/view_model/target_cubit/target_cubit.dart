import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/services/home_widget_service.dart';
import '../../../../nutrition/presentation/view_model/nutrition_cubit.dart';
import '../../../../nutrition/presentation/view_model/nutrition_state.dart';
import '../../../data/models/target_model.dart';
import '../../../data/repository/target_repository.dart';
import 'target_state.dart';

class TargetCubit extends Cubit<TargetState> {
  final TargetRepository _repository;

  TargetCubit(this._repository) : super(TargetInitial());

  // 🔥 دالة صغيرة لتحديث الويدجت الخارجي لما الهدف يتغير
  // 🔥 دالة تحديث الويدجت الخارجي بكل الماكروز لما الهدف يتغير
  void _updateHomeWidgetWithNewTarget(TargetModel newTarget) {
    try {
      // بنجيب القيم اللي أكلها المستخدم حالياً من NutritionCubit
      final nutritionCubit = getIt<NutritionCubit>();
      final nutritionState = nutritionCubit.state;

      int currentCalories = 0;
      int currentProtein = 0;
      int currentCarbs = 0;
      int currentFat = 0;

      if (nutritionState is NutritionSuccess) {
        final totalConsumed = nutritionState.foodLogs.total;
        currentCalories = totalConsumed.calories.toInt();
        currentProtein = totalConsumed.protein.toInt();
        currentCarbs = totalConsumed.carbs.toInt();
        currentFat = totalConsumed.fat.toInt();
      }

      // بنحدث الويدجت الخارجي بالقيم الحالية + الأهداف الجديدة كاملة
      HomeWidgetService.updateCaloriesWidget(
        currentCalories: currentCalories,
        targetCalories: newTarget.calories.toInt(),
        currentProtein: currentProtein,
        targetProtein: newTarget.protein.toInt(),
        currentCarbs: currentCarbs,
        targetCarbs: newTarget.carbs.toInt(),
        currentFat: currentFat,
        targetFat: newTarget.fat.toInt(),
      );
    } catch (e) {
      print("Error updating home widget from TargetCubit: $e");
    }
  }

  Future<void> fetchLatestTarget() async {
    //  لا تظهري التحميل إلا إذا لم يكن لدينا داتا سابقة
    if (state is! TargetSuccess) {
      emit(TargetLoading());
    }

    final result = await _repository.getLatestTarget();

    if (isClosed) return; // حماية من الكراش

    switch (result) {
      case Success():
      // 🔥 تحديث الويدجت بالهدف الجديد اللي إجا من السيرفر
        _updateHomeWidgetWithNewTarget(result.data);
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
      // 🔥 تحديث الويدجت فوراً لما المستخدم يغير هدفه (تضخيم/تنشيف...)
        _updateHomeWidgetWithNewTarget(result.data);
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