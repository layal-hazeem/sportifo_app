import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';

abstract class EditCoachPlanState {
  const EditCoachPlanState();
}

class EditCoachPlanInitial extends EditCoachPlanState {
  const EditCoachPlanInitial();
}

class EditCoachPlanLoading extends EditCoachPlanState {
  const EditCoachPlanLoading();
}

class EditCoachPlanSuccess extends EditCoachPlanState {
  final PlanDetailsResponseModel response;

  const EditCoachPlanSuccess(this.response);
}

class EditCoachPlanFailure extends EditCoachPlanState {
  final String message;

  const EditCoachPlanFailure(this.message);
}