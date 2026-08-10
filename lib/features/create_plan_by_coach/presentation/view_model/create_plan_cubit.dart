import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/view_model/create_plan_state.dart';
import '../../data/models/create_plan_request.dart';
import '../../data/repository/create_plan_repository.dart';

class CreatePlanCubit extends Cubit<CreatePlanState> {
  final CreatePlanRepository repository;

  CreatePlanCubit(this.repository)
      : super(CreatePlanInitial());

  Future<void> createPlan(
      CreatePlanRequest request) async {
    emit(CreatePlanLoading());

    try {
      await repository.createPlan(request);

      emit(CreatePlanSuccess());
    } catch (e) {
      emit(CreatePlanError(
        e.toString(),
      ));
    }
  }
  
}