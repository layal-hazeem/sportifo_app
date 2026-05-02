import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'exercises_state.dart';
// تأكدي من استيراد ApiResult


class ExercisesCubit extends Cubit<ExercisesState> {
  final WorkoutRepository _repository;

  ExercisesCubit(this._repository) : super(ExercisesInitial());

  // الدالة التي سنستدعيها من الـ UI
  Future<void> fetchExercises({int? categoryId, int? organId, int? partId}) async {
    emit(ExercisesLoading());

    final result = await _repository.getExercises(
      categoryId: categoryId,
      organId: organId,
      partId: partId,
    );

    switch (result) {
      case Success():
        emit(ExercisesSuccess(result.data));
        break;
      case Failure():
        emit(ExercisesFailure(result.message));
        break;
    }
  }
}