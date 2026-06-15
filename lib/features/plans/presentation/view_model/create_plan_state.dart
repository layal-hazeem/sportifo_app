abstract class CreatePlanState {}

class CreatePlanInitial extends CreatePlanState {}

class CreatePlanLoading extends CreatePlanState {}

class CreatePlanSuccess extends CreatePlanState {}

class CreatePlanError extends CreatePlanState {
  final String message;

  CreatePlanError(this.message);
}