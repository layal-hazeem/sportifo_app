import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_model.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_request.dart';

import '../web_services/edit_coach_plan_service.dart';

class EditCoachPlanRepository {
  final EditCoachPlanService webService;

  EditCoachPlanRepository(this.webService);

Future<PlanResponseModel> updatePlan({
  required int planId,
  required EditCoachPlanRequest request,
}) async {
  final response = await webService.updatePlan(
    planId: planId,
    requestBody: request.toJson(),
  );

  return PlanResponseModel.fromJson(response);
}
}