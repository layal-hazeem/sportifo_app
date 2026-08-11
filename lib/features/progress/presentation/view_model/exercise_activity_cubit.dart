import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../data/repository/exercise_activity_repository.dart';
import '../../data/models/exercise_activity_model.dart';
import 'exercise_activity_state.dart';

class ExerciseActivityCubit extends Cubit<ExerciseActivityState> {
  final ExerciseActivityRepository _repository;

  ExerciseActivityCubit(this._repository) : super(ExerciseActivityInitial());

  Future<void> fetchActivity({
    int? planId,
    int? exerciseId,
    String? from,
    String? to,
    bool forceRefresh = false,
  }) async {
    emit(ExerciseActivityLoading());
    final result = await _repository.getExerciseActivity(
      planId: planId,
      exerciseId: exerciseId,
      from: from,
      to: to,
      forceRefresh: forceRefresh,
    );

    if (isClosed) return;

    if (result is Success<List<DayActivity>>) {
      emit(ExerciseActivitySuccess(result.data));
    } else if (result is Failure) {
      emit(ExerciseActivityError((result as Failure).message));
    }
  }
}
