import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_model.dart';
import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_request.dart';
import 'package:sportifo_app/features/edit_self_plan/data/web_services/edit_self_plan_service.dart';

class EditSelfPlanRepository {
  final EditSelfPlanService service;

  EditSelfPlanRepository(this.service);

  Future<SelfPlanResponseModel> updateSelfPlan({
    required int planId,
    required EditSelfPlanRequest request,
  }) async {
    return await service.updateSelfPlan(
      planId: planId,
      body: request.toJson(),
    );
  }
}