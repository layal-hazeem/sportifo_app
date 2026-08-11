import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/food_log_model.dart';
import '../web_services/nutrition_web_service.dart';

class NutritionRepository {
  final NutritionWebService _webService;

  NutritionRepository(this._webService);

  Future<ApiResult<TodayFoodLogsResponse>> getTodayFoodLogs({
    bool forceRefresh = false,
  }) async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final policy = forceRefresh ? CachePolicy.noCache : CachePolicy.refresh;

      final dioOptions = cacheOptions.copyWith(policy: policy).toOptions();

      final response = await _webService.getTodayFoodLogs(options: dioOptions);
      final responseData = TodayFoodLogsResponse.fromJson(
        response.data['data'],
      );
      return Success(responseData);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

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
}