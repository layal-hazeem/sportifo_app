import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class NutritionWebService {
  final Dio dio;

  NutritionWebService(this.dio);

  Future<Response> getTodayFoodLogs({Options? options}) async {
    return await dio.get(ApiConstants.todayFoodLogs, options: options);
  }

  Future<Response> addMealFromAi(int messageId, {Options? options}) async {
    return await dio.post(
      '${ApiConstants.addMealFromAi}/$messageId',
      options: options,
    );
  }

  Future<Response> addManualMeal(FormData formData, {Options? options}) async {
    return await dio.post(
      ApiConstants.addManualMeal,
      data: formData,
      options: options,
    );
  }

  Future<Response> deleteMeal(int mealId, {Options? options}) async {
    return await dio.delete(
      '${ApiConstants.deleteMeal}/$mealId',
      options: options,
    );
  }
}
