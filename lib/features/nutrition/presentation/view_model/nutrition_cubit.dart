import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final Map<int, int> _messageToMealMap = {};
  TodayFoodLogsResponse? _lastSuccessfulResponse;
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

    await _loadMessageToMealMap();

    final result = await _repository.getTodayFoodLogs(forceRefresh: false);

    if (!isClosed) {
      if (result is Success<TodayFoodLogsResponse>) {
        final logs = result.data.logs;
        final validMealIds = logs.map((l) => l.id).toSet();

        _messageToMealMap.removeWhere((msgId, mealId) => !validMealIds.contains(mealId));
        await _saveMessageToMealMap();

        _lastSuccessfulResponse = result.data;
        await _saveFoodLogsToCache(result.data);
        _updateHomeWidget(result.data);
        emit(NutritionSuccess(foodLogs: result.data));
      } else if (result is Failure) {
        final cached = await _loadFoodLogsFromCache();
        if (cached != null) {
          _lastSuccessfulResponse = cached;
          _updateHomeWidget(cached);
          emit(NutritionSuccess(foodLogs: cached));
        } else {
          emit(NutritionError((result as Failure).message));
        }
      }
    }

    _isInitialized = true;
  }

  Future<void> _loadMessageToMealMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapString = prefs.getString('nutrition_message_meal_map') ?? '{}';
      _messageToMealMap.clear();

      if (mapString.isNotEmpty && mapString != '{}') {
        final pairs = mapString.split(',');
        for (final pair in pairs) {
          final parts = pair.split(':');
          if (parts.length == 2) {
            _messageToMealMap[int.parse(parts[0])] = int.parse(parts[1]);
          }
        }
      }
    } catch (e) {}
  }

  Future<void> _saveMessageToMealMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_messageToMealMap.isEmpty) {
        await prefs.setString('nutrition_message_meal_map', '{}');
      } else {
        final mapString = _messageToMealMap.entries
            .map((e) => '${e.key}:${e.value}')
            .join(',');
        await prefs.setString('nutrition_message_meal_map', mapString);
      }
    } catch (e) {}
  }

  Future<void> _saveFoodLogsToCache(TodayFoodLogsResponse data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString('nutrition_food_logs_cache', jsonString);
    } catch (e) {}
  }

  Future<TodayFoodLogsResponse?> _loadFoodLogsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('nutrition_food_logs_cache');
      if (jsonString == null || jsonString.isEmpty) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return TodayFoodLogsResponse.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchTodayFoodLogs({bool forceRefresh = false}) async {
    if (!forceRefresh && _lastSuccessfulResponse != null && !isClosed) {
      emit(NutritionSuccess(foodLogs: _lastSuccessfulResponse!));
      return;
    }

    emit(NutritionLoading());

    final result = await _repository.getTodayFoodLogs(forceRefresh: forceRefresh);

    if (isClosed) return;

    if (result is Success<TodayFoodLogsResponse>) {
      _lastSuccessfulResponse = result.data;
      await _saveFoodLogsToCache(result.data);
      _updateHomeWidget(result.data);
      emit(NutritionSuccess(foodLogs: result.data));
    } else if (result is Failure) {
      final cached = await _loadFoodLogsFromCache();
      if (cached != null) {
        _lastSuccessfulResponse = cached;
        emit(NutritionSuccess(foodLogs: cached));
      } else if (_lastSuccessfulResponse != null) {
        emit(NutritionSuccess(foodLogs: _lastSuccessfulResponse!));
      } else {
        emit(NutritionError((result as Failure).message));
      }
    }
  }

  bool isMealLogged(int messageId) {
    return _messageToMealMap.containsKey(messageId);
  }

  bool isMessageSaved(ChatMessageModel message) {
    if (message.sender != 'ai' || !message.hasNutritionData()) return false;

    if (_messageToMealMap.containsKey(message.id)) return true;

    final logs = _lastSuccessfulResponse?.logs ?? [];
    final normalizedMsgBody = _normalizeBody(message.body);

    return logs.any((log) {
      if (log.isManual) return false;
      return _normalizeBody(log.body) == normalizedMsgBody;
    });
  }

  String _normalizeBody(String body) {
    return body.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  }

  Future<void> addMealFromAi(int messageId) async {
    emit(AddMealLoading(messageId));

    final result = await _repository.addMealFromAi(messageId);

    if (isClosed) return;

    if (result is Success<AddMealResponse>) {
      if (result.data.logs.isNotEmpty) {
        final mealId = result.data.logs.first.id;
        _messageToMealMap[messageId] = mealId;
        await _saveMessageToMealMap();
      }

      await fetchTodayFoodLogs(forceRefresh: true);
      _updateHomeWidget(_lastSuccessfulResponse!);
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
        _lastSuccessfulResponse = TodayFoodLogsResponse(
          logs: result.data.logs,
          total: result.data.total,
        );
        await _saveFoodLogsToCache(_lastSuccessfulResponse!);
        _updateHomeWidget(_lastSuccessfulResponse!);
        emit(AddMealSuccess(mealResponse: result.data));

        await fetchTodayFoodLogs(forceRefresh: true);
      } else if (result is Failure) {
        emit(AddMealError(message: (result as Failure).message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(AddMealError(message: 'Something went wrong'));
      }
    }
  }

  Future<void> deleteMeal(int mealId) async {
    emit(DeleteMealLoading(mealId));

    final result = await _repository.deleteMeal(mealId);

    if (isClosed) return;

    if (result is Success<AddMealResponse>) {
      _messageToMealMap.removeWhere((key, value) => value == mealId);
      await _saveMessageToMealMap();

      _lastSuccessfulResponse = TodayFoodLogsResponse(
        logs: result.data.logs,
        total: result.data.total,
      );
      await _saveFoodLogsToCache(_lastSuccessfulResponse!);
      _updateHomeWidget(_lastSuccessfulResponse!);
      emit(NutritionSuccess(foodLogs: _lastSuccessfulResponse!));
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
  // ✅ دالة جديدة - بتصفر كل شي بالذاكرة وبتمسح الكاش المحلي الخاص بالتغذية
  Future<void> reset() async {
    _isInitialized = false;
    _lastSuccessfulResponse = null;
    _messageToMealMap.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nutrition_food_logs_cache');
    await prefs.remove('nutrition_message_meal_map');

    emit(NutritionInitial());
  }
}