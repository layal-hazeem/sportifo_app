import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_request.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';

import '../web_services/edit_coach_plan_service.dart';

class EditCoachPlanRepository {
  final EditCoachPlanService _service;

  EditCoachPlanRepository(this._service);

  Future<ApiResult<PlanDetailsResponseModel>> updatePlan({
    required int planId,
    required EditCoachPlanRequest request,
  }) async {
    try {
      final response = await _service.updatePlan(
        planId,
        request.toMap(),
      );

      final data = PlanDetailsResponseModel.fromJson(
        response.data,
      );

      return Success(data);
    } catch (error) {
      return Failure(error.toString());
    }
  }
}