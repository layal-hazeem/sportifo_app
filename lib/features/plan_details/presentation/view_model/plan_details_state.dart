import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';

abstract class PlanDetailsState {
const PlanDetailsState();
}

class PlanDetailsInitial extends PlanDetailsState {
const PlanDetailsInitial();
}

class PlanDetailsLoading extends PlanDetailsState {
const PlanDetailsLoading();
}

class PlanDetailsSuccess extends PlanDetailsState {
final PlanDetailsResponseModel response;

const PlanDetailsSuccess(this.response);
}

class PlanDetailsFailure extends PlanDetailsState {
final String message;

const PlanDetailsFailure(this.message);
}
