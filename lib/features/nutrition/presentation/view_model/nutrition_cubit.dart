import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/food_log_model.dart';
import '../../data/repository/nutrition_repository.dart';
import '../../../ai_chat/data/models/chat_message_model.dart';
import '../../../../core/network/api_result.dart';
import 'nutrition_state.dart';
import '../../../../core/services/home_widget_service.dart';
import '../../../targets/presentation/view_model/target_cubit/target_cubit.dart';
import '../../../targets/presentation/view_model/target_cubit/target_state.dart';
import '../../../../core/di/service_locator.dart';

class NutritionCubit extends Cubit<NutritionState> {
  final NutritionRepository _repository;
  bool _isInitialized = false;

  NutritionCubit(this._repository) : super(NutritionInitial());

  void _updateHomeWidget(TodayFoodLogsResponse data) {
    try {
      final targetCubit = getIt<TargetCubit>();
      final targetState = targetCubit.state;

      num targetCalories = 2000;
      num targetProtein = 120;
      num targetCarbs = 150;
      num targetFat = 60;

      if (targetState is TargetSuccess) {
        targetCalories = targetState.targetData.calories;
        targetProtein = targetState.targetData.protein;
        targetCarbs = targetState.targetData.carbs;
        targetFat = targetState.targetData.fat;
      }

      HomeWidgetService.updateCaloriesWidget(
        currentCalories: data.total.calories.toInt(),
        targetCalories: targetCalories.toInt(),
        currentProtein: data.total.protein.toInt(),
        targetProtein: targetProtein.toInt(),
        currentCarbs: data.total.carbs.toInt(),
        targetCarbs: targetCarbs.toInt(),
        currentFat: data.total.fat.toInt(),
        targetFat: targetFat.toInt(),
      );
    } catch (e) {
      print("Error updating home widget from NutritionCubit: $e");
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await fetchTodayFoodLogs(forceRefresh: false);
    _isInitialized = true;
  }

  Future<void> fetchTodayFoodLogs({bool forceRefresh = false}) async {
    emit(NutritionLoading());

    final result = await _repository.getTodayFoodLogs(forceRefresh: forceRefresh);

    if (isClosed) return;

    if (result is Success<TodayFoodLogsResponse>) {
      _updateHomeWidget(result.data);
      emit(NutritionSuccess(foodLogs: result.data));
    } else if (result is Failure) {
      emit(NutritionError((result as Failure).message));
    }
  }

  // دالة التحقق من تسجيل الوجبة
  Future<bool> isMealLogged(int messageId) async {
    final mealId = await _repository.getMealIdForMessage(messageId);
    return mealId != null;
  }

  // دالة التحقق من أن رسالة AI محفوظة كوجبة (تعتمد على الخريطة أو مقارنة النص)
  Future<bool> isMessageSaved(ChatMessageModel message) async {
    if (message.sender != 'ai' || !message.hasNutritionData()) return false;

    // أولاً نتحقق من الخريطة
    final mealId = await _repository.getMealIdForMessage(message.id);
    if (mealId != null) return true;

    // ثم نتحقق من الوجبات الحالية (نحتاج لجلبها)
    final result = await _repository.getTodayFoodLogs(forceRefresh: false);
    if (result is Success<TodayFoodLogsResponse>) {
      final logs = result.data.logs;
      final normalizedMsgBody = _normalizeBody(message.body);
      return logs.any((log) {
        if (log.isManual) return false;
        return _normalizeBody(log.body) == normalizedMsgBody;
      });
    }
    return false;
  }

  String _normalizeBody(String body) {
    return body.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  }

  // إضافة وجبة من AI
  Future<void> addMealFromAi(int messageId) async {
    emit(AddMealLoading(messageId));

    final result = await _repository.addMealFromAi(messageId);

    if (isClosed) return;

    if (result is Success<AddMealResponse>) {
      if (result.data.logs.isNotEmpty) {
        final mealId = result.data.logs.first.id;
        await _repository.addMessageMealMapping(messageId, mealId);
      }

      // تحديث البيانات (سيجلب الكاش الجديد)
      await fetchTodayFoodLogs(forceRefresh: true);
      emit(AddMealSuccess(
        messageId: messageId,
        mealResponse: result.data,
      ));
    } else if (result is Failure) {
      emit(AddMealError(
        messageId: messageId,
        message: (result as Failure).message,
      ));
    }
  }

  // إضافة وجبة يدوية
  Future<void> addManualMeal({
    required String body,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    emit(AddMealLoading());

    try {
      final result = await _repository.addManualMeal(
        body: body,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

      if (isClosed) return;

      if (result is Success<AddMealResponse>) {
        await fetchTodayFoodLogs(forceRefresh: true);
        emit(AddMealSuccess(mealResponse: result.data));
      } else if (result is Failure) {
        emit(AddMealError(message: (result as Failure).message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(AddMealError(message: 'Something went wrong'));
      }
    }
  }

  // حذف وجبة
  Future<void> deleteMeal(int mealId) async {
    emit(DeleteMealLoading(mealId));

    final result = await _repository.deleteMeal(mealId);

    if (isClosed) return;

    if (result is Success<AddMealResponse>) {
      await _repository.removeMealMapping(mealId);
      await fetchTodayFoodLogs(forceRefresh: true);
      emit(DeleteMealSuccess(
        mealId: mealId,
        mealResponse: result.data,
      ));
    } else if (result is Failure) {
      emit(DeleteMealError(
        mealId: mealId,
        message: (result as Failure).message,
      ));
    }
  }

  // دالة reset (عند تسجيل الخروج) - نمسح كل شيء
void reset() {
  _repository.clearAllMappings(); // أو _repository.clearFoodLogs() إذا أردت مسح الكاش أيضاً
  _isInitialized = false;
  if (!isClosed) emit(NutritionInitial());
}
}