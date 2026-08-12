import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_request.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/repository/edit_coach_plan_repository.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';

import 'edit_coach_plan_state.dart';

class EditCoachPlanCubit extends Cubit<EditCoachPlanState> {
  final EditCoachPlanRepository _repository;

  EditCoachPlanCubit(this._repository)
      : super(const EditCoachPlanInitial());

  Future<void> updatePlan({
    required int planId,
    required EditCoachPlanRequest request,
  }) async {
    emit(const EditCoachPlanLoading());

    final result = await _repository.updatePlan(
      planId: planId,
      request: request,
    );

    if (result is Success<PlanDetailsResponseModel>) {
      emit(EditCoachPlanSuccess(result.data));
    } else if (result is Failure<PlanDetailsResponseModel>) {
      emit(EditCoachPlanFailure(result.message));
    }
  }
}