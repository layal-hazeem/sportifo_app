import '../models/create_plan_request.dart';
import '../models/create_plan_response.dart';
import '../web_services/create_plan_service.dart';

class CreatePlanRepository {
  final CreatePlanService service;

  CreatePlanRepository(this.service);

  Future<CreatePlanResponse> createPlan(
      CreatePlanRequest request) async {

    final response =
        await service.createPlan(request.toMap());

    return CreatePlanResponse.fromJson(
      response.data,
    );
  }
}