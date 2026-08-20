import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_model.dart';
import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_request.dart';
import 'package:sportifo_app/features/edit_self_plan/data/web_services/edit_self_plan_service.dart';

class EditSelfPlanRepository {
  final EditSelfPlanService service;

  EditSelfPlanRepository(this.service);

  Future<SelfPlanResponseModel> updateSelfPlan(
    int planId,
    EditSelfPlanRequest request,
  ) async {
    final response = await service.updateSelfPlan(
      planId,
      request.toJson(),
    );

    return SelfPlanResponseModel.fromJson(
      response.data,
    );
  }
}