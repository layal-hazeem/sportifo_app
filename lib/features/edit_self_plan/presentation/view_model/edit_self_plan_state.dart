import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_model.dart';

abstract class EditSelfPlanState {}

class EditSelfPlanInitial extends EditSelfPlanState {}

class EditSelfPlanLoading extends EditSelfPlanState {}

class EditSelfPlanSuccess extends EditSelfPlanState {
  final SelfPlanResponseModel response;

  EditSelfPlanSuccess(this.response);
}

class EditSelfPlanError extends EditSelfPlanState {
  final String error;

  EditSelfPlanError(this.error);
}