import 'package:flutter/foundation.dart'; // 👈 1. ضفنا هاد الاستيراد ضروري جداً عشان الـ compute
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart'; // 👈 إياكي تنسيها
import '../../../../core/network/dio_factory.dart'; // 👈 إياكي تنسيها
import '../../../../core/network/api_result.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../my_plans(user)/data/models/my_plan_model.dart';
import '../service/platform_plans_service.dart';

List<PlanModel> _parsePlatformPlansList(dynamic data) {
  final list = data as List<dynamic>;
  return list.map((json) => PlanModel.fromJson(json)).toList();
}

class PlatformPlansRepository {
  final PlatformPlansWebService _webService;

  PlatformPlansRepository(this._webService);

  Future<ApiResult<List<PlanModel>>> getPlatformPlans() async {
    try {
      final cacheOptions = await DioFactory.getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache,
      ).toOptions();

      final response = await _webService.getPlatformPlans(options: dioOptions);

      final List data = response.data['data']['data'] ?? [];

      final List<PlanModel> plans = await compute(_parsePlatformPlansList, data);

      return Success(plans);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<String>> toggleSavePlan(int planId) async {
    try {
      final response = await _webService.toggleSavePlan(planId);
      return Success(response.data['message']);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}