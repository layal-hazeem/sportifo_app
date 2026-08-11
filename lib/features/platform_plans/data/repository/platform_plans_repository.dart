import '../../../../core/network/api_result.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../my_plans(user)/data/models/my_plan_model.dart';
import '../service/platform_plans_service.dart';

class PlatformPlansRepository {
  final PlatformPlansWebService _webService;

  PlatformPlansRepository(this._webService);

  Future<ApiResult<List<PlanModel>>> getPlatformPlans() async {
    try {
      final response = await _webService.getPlatformPlans();

      final List data = response.data['data']['data'] ?? [];
      final List<PlanModel> plans = data.map((json) => PlanModel.fromJson(json)).toList();

      return Success(plans);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> toggleSavePlan(int planId) async {
    try {
      await _webService.toggleSavePlan(planId);
      return  Success(null);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}