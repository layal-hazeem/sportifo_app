import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';
import '../web_services/plan_details_web_service.dart';

class PlanDetailsRepository {
  final PlanDetailsWebService _webService;

  PlanDetailsRepository(this._webService);

  Future<ApiResult<PlanDetailsResponseModel>> getPlanDetails(int planId) async {
    try {
      final response = await _webService.getPlanDetails(planId);

      final data = PlanDetailsResponseModel.fromJson(response.data);

      return Success(data);
    } catch (error) {
      return Failure(error.toString());
    }
  }
}
