abstract class EditCoachPlanState {}

class EditCoachPlanInitial extends EditCoachPlanState {}

class EditCoachPlanLoading extends EditCoachPlanState {}

class EditCoachPlanSuccess extends EditCoachPlanState {
  final String message;
  EditCoachPlanSuccess(this.message);
}

class EditCoachPlanError extends EditCoachPlanState {
  final String error;
  EditCoachPlanError(this.error);
}