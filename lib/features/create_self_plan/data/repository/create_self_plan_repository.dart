import '../models/create_self_plan_request.dart';
import '../models/create_self_plan_response.dart';
import '../web_services/create_self_plan_service.dart';

class CreateSelfPlanRepository {
  final CreateSelfPlanService service;

  CreateSelfPlanRepository(this.service);

  Future<CreateSelfPlanResponse> createSelfPlan(
    CreateSelfPlanRequest request,
  ) async {
    final response = await service.createSelfPlan(
      request.toMap(),
    );

    return CreateSelfPlanResponse.fromJson(
      response.data,
    );
  }
}