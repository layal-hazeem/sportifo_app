import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';
import 'package:sportifo_app/features/plan_details/data/repository/plan_details_repository.dart';
import 'plan_details_state.dart';

class PlanDetailsCubit extends Cubit<PlanDetailsState> {
  final PlanDetailsRepository _repository;

  PlanDetailsCubit(this._repository) : super(const PlanDetailsInitial());

  Future<void> getPlanDetails(int planId) async {
    emit(const PlanDetailsLoading());

    final result = await _repository.getPlanDetails(planId);

    if (result is Success<PlanDetailsResponseModel>) {
      emit(PlanDetailsSuccess(result.data));
    } else if (result is Failure<PlanDetailsResponseModel>) {
      emit(PlanDetailsFailure(result.message));
    }
  }
}
