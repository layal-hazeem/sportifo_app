import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/trainees/data/models/coach_plan_model.dart';
import 'package:sportifo_app/features/trainees/data/repository/trainees_repository.dart';

import 'trainees_state.dart';

class TraineesCubit extends Cubit<TraineesState> {
  final TraineesRepository _repository;

  TraineesCubit(this._repository) : super(const TraineesInitial());

  // التحميل العادي
  Future<void> getCoachTrainees() async {
    emit(const TraineesLoading());

    final ApiResult<CoachPlansResponseModel> result = await _repository
        .getCoachTrainees();

    if (result is Success<CoachPlansResponseModel>) {
      emit(TraineesSuccess(result.data));
    } else if (result is Failure<CoachPlansResponseModel>) {
      emit(TraineesFailure(result.message));
    }
  }

  // Pull to Refresh
  Future<void> refreshCoachTrainees() async {
    final ApiResult<CoachPlansResponseModel> result = await _repository
        .getCoachTrainees(forceRefresh: true);

    if (result is Success<CoachPlansResponseModel>) {
      emit(TraineesSuccess(result.data));
    } else if (result is Failure<CoachPlansResponseModel>) {
      print('🚨 TRAINEES REFRESH ERROR: ${result.message}');
    }
  }
}
