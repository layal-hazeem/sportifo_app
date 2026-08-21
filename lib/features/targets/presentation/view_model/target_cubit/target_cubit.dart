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

  void _updateHomeWidgetWithNewTarget(TargetModel newTarget) {
    try {
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
    if (state is! TargetSuccess) {
      emit(TargetLoading());
    }

    final result = await _repository.getLatestTarget();

    if (isClosed) return;

    switch (result) {
      case Success():
        _updateHomeWidgetWithNewTarget(result.data);
        emit(TargetSuccess(result.data));
        break;
      case Failure(message: final errorMsg):
        if (errorMsg.contains("No Internet") || errorMsg.contains("Connection timeout")) {
          if (state is TargetSuccess) return;
        }

        // 🔥 التعديل الجوهري هنا: حولنا الرسالة لـ lowercase لحتى يطابق صح 100%
        final lowerMsg = errorMsg.toLowerCase();
        if (lowerMsg.contains("no targets") || lowerMsg.contains("not found")) {
          emit(TargetNotSet()); // ✅ رح تضرب هون فوراً ويطلع كارد (Set My Goal Now)
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

  void reset() {
    emit(TargetInitial());
  }
}