import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/create_self_plan/data/models/create_self_plan_request.dart';
import 'package:sportifo_app/features/create_self_plan/data/models/create_self_plan_response.dart';
import 'package:sportifo_app/features/create_self_plan/data/repository/create_self_plan_repository.dart';

import 'create_self_plan_state.dart';

class CreateSelfPlanCubit extends Cubit<CreateSelfPlanState> {
  final CreateSelfPlanRepository repository;

  CreateSelfPlanCubit(this.repository)
      : super(CreateSelfPlanInitial());

  Future<void> createSelfPlan(
    CreateSelfPlanRequest request,
  ) async {
    emit(CreateSelfPlanLoading());

    try {
      final CreateSelfPlanResponse response =
          await repository.createSelfPlan(request);

      emit(CreateSelfPlanSuccess(response));
    } catch (e) {
      emit(
        CreateSelfPlanError(
          e.toString(),
        ),
      );
    }
  }
}