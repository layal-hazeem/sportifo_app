import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:sportifo_app/core/storage/local_storage.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../models/food_log_model.dart';
import '../web_services/nutrition_web_service.dart';

class NutritionRepository {
  final NutritionWebService _webService;
  final LocalStorage _localStorage;
  Box<String>? _foodBox;
  Box<String>? _mappingBox;

  NutritionRepository(this._webService, this._localStorage) {
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    _foodBox ??= await Hive.openBox<String>('nutrition_cache');
    _mappingBox ??= await Hive.openBox<String>('nutrition_mapping_cache');
  }

  // ---------- Food Logs Caching ----------
  String get _foodLogsKey {
    final uid = _localStorage.getUserId() ?? 'guest';
    return 'food_logs_$uid';
  }

  TodayFoodLogsResponse? getCachedFoodLogs() {
    if (_foodBox == null) return null;
    final raw = _foodBox!.get(_foodLogsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return TodayFoodLogsResponse.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveFoodLogs(TodayFoodLogsResponse data) async {
    await _initBoxes();
    final encoded = jsonEncode(data.toJson());
    await _foodBox!.put(_foodLogsKey, encoded);
  }

  Future<ApiResult<TodayFoodLogsResponse>> getTodayFoodLogs({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        await _initBoxes();
        final cached = getCachedFoodLogs();
        if (cached != null) {
          return Success(cached);
        }
      }

      final response = await _webService.getTodayFoodLogs();
      final responseData = TodayFoodLogsResponse.fromJson(
        response.data['data'],
      );

      await _saveFoodLogs(responseData);
      return Success(responseData);
    } catch (e) {
      final cached = getCachedFoodLogs();
      if (cached != null) {
        return Success(cached);
      }
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  // ---------- Message-Meal Mapping ----------
  String get _mappingKey {
    final uid = _localStorage.getUserId() ?? 'guest';
    return 'mapping_$uid';
  }

  // تحميل الخريطة من Hive
  Future<Map<int, int>> loadMessageMealMapping() async {
    await _initBoxes();
    final raw = _mappingBox!.get(_mappingKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((key, value) => MapEntry(int.parse(key), value as int));
    } catch (_) {
      return {};
    }
  }

  // حفظ الخريطة بالكامل
  Future<void> _saveMessageMealMapping(Map<int, int> mapping) async {
    await _initBoxes();
    final encoded = jsonEncode(mapping);
    await _mappingBox!.put(_mappingKey, encoded);
  }

  // إضافة علاقة جديدة
  Future<void> addMessageMealMapping(int messageId, int mealId) async {
    final mapping = await loadMessageMealMapping();
    mapping[messageId] = mealId;
    await _saveMessageMealMapping(mapping);
  }

  // حذف علاقة بواسطة mealId
  Future<void> removeMealMapping(int mealId) async {
    final mapping = await loadMessageMealMapping();
    mapping.removeWhere((key, value) => value == mealId);
    await _saveMessageMealMapping(mapping);
  }

  // الحصول على mealId من messageId
  Future<int?> getMealIdForMessage(int messageId) async {
    final mapping = await loadMessageMealMapping();
    return mapping[messageId];
  }

  // مسح كل الخريطة (عند تسجيل الخروج)
  Future<void> clearAllMappings() async {
    await _initBoxes();
    await _mappingBox!.delete(_mappingKey);
  }

  // ---------- API Operations ----------
  Future<ApiResult<AddMealResponse>> addMealFromAi(int messageId) async {
    try {
      final response = await _webService.addMealFromAi(messageId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final mealResponse = AddMealResponse.fromJson(response.data['data']);
        await getTodayFoodLogs(forceRefresh: true);
        return Success(mealResponse);
      }

      return Failure("Failed to add meal");
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<AddMealResponse>> addManualMeal({
    required String body,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    try {
      final formData = FormData.fromMap({
        'body': body,
        'calories': calories.toString(),
        'protein': protein.toString(),
        'carbs': carbs.toString(),
        'fat': fat.toString(),
      });

      final response = await _webService.addManualMeal(formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final mealResponse = AddMealResponse.fromJson(response.data['data']);
        await getTodayFoodLogs(forceRefresh: true);
        return Success(mealResponse);
      }

      return Failure("Failed to add manual meal");
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<AddMealResponse>> deleteMeal(int mealId) async {
    try {
      final response = await _webService.deleteMeal(mealId);

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        final mealResponse = AddMealResponse.fromJson(response.data['data']);
        await getTodayFoodLogs(forceRefresh: true);
        return Success(mealResponse);
      }

      return Failure("Failed to delete meal");
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }


  // مسح الكاش الخاص بالـ food logs للمستخدم الحالي
Future<void> clearFoodLogs() async {
  await _initBoxes();
  await _foodBox!.delete(_foodLogsKey);
}
}