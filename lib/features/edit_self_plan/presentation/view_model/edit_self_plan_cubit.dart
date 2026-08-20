import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_request.dart';
import 'package:sportifo_app/features/edit_self_plan/data/repository/edit_self_plan_repository.dart';
import 'package:sportifo_app/features/edit_self_plan/presentation/view_model/edit_self_plan_state.dart';


class EditSelfPlanCubit extends Cubit<EditSelfPlanState> {
  final EditSelfPlanRepository repository;

  EditSelfPlanCubit(this.repository)
      : super(EditSelfPlanInitial());

  Future<void> updateSelfPlan(
    int planId,
    EditSelfPlanRequest request,
  ) async {
    emit(EditSelfPlanLoading());

    try {
      final response = await repository.updateSelfPlan(
        planId,
        request,
      );

      emit(
        EditSelfPlanSuccess(response),
      );
    } catch (e) {
      emit(
        EditSelfPlanError(
          e.toString(),
        ),
      );
    }
  }
}