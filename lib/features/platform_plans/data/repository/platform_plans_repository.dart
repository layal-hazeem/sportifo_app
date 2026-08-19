import 'package:dio_cache_interceptor/dio_cache_interceptor.dart'; // 👈 إياكي تنسيها
import 'package:get_it/get_it.dart';
import '../../../../core/network/dio_factory.dart'; // 👈 إياكي تنسيها
import '../../../../core/network/api_result.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../my_plans(user)/data/models/my_plan_model.dart';
import '../service/platform_plans_service.dart';

class PlatformPlansRepository {
  final PlatformPlansWebService _webService;

  PlatformPlansRepository(this._webService);

  Future<ApiResult<List<PlanModel>>> getPlatformPlans() async {
    try {
      // 🔥 التعويذة السحرية لكسر كاش الباك إند اللي مدته 7 أيام!
      final cacheOptions = await GetIt.instance<DioFactory>().getCacheOptions();
      final dioOptions = cacheOptions.copyWith(
        policy: CachePolicy.refreshForceCache, // إجبار التحديث
      ).toOptions();

      final response = await _webService.getPlatformPlans(options: dioOptions);

      final List data = response.data['data']['data'] ?? [];
      final List<PlanModel> plans = data.map((json) => PlanModel.fromJson(json)).toList();

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