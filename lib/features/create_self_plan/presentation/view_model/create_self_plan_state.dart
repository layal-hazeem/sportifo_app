import 'package:sportifo_app/features/create_self_plan/data/models/create_self_plan_response.dart';

abstract class CreateSelfPlanState {}

class CreateSelfPlanInitial extends CreateSelfPlanState {}

class CreateSelfPlanLoading extends CreateSelfPlanState {}

class CreateSelfPlanSuccess extends CreateSelfPlanState {
  final CreateSelfPlanResponse response;

  CreateSelfPlanSuccess(this.response);
}

class CreateSelfPlanError extends CreateSelfPlanState {
  final String message;

  CreateSelfPlanError(this.message);
}