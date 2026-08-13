import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_request.dart';
import '../../data/repository/edit_coach_plan_repository.dart';
import 'edit_coach_plan_state.dart';

class EditCoachPlanCubit extends Cubit<EditCoachPlanState> {
  final EditCoachPlanRepository repository;

  EditCoachPlanCubit(this.repository) : super(EditCoachPlanInitial());

  Future<void> updatePlan({
    required int planId,
    required EditCoachPlanRequest requestBody,
  }) async {
    emit(EditCoachPlanLoading());
    try {
      final result = await repository.updatePlan(
        planId: planId,
        request: requestBody,
      );
      emit(EditCoachPlanSuccess(result.message));
    } catch (e) {
      emit(EditCoachPlanError(e.toString()));
    }
  }
}