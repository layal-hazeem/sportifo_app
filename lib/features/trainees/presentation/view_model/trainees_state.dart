import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';

abstract class TraineesState {
  const TraineesState();
}

class TraineesInitial extends TraineesState {
  const TraineesInitial();
}

class TraineesLoading extends TraineesState {
  const TraineesLoading();
}

class TraineesSuccess extends TraineesState {
  final CoachPlansResponseModel response;

  const TraineesSuccess(this.response);
}

class TraineesFailure extends TraineesState {
  final String message;

  const TraineesFailure(this.message);
}