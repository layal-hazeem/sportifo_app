import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'exercises_state.dart';

class ExercisesCubit extends Cubit<ExercisesState> {
  final WorkoutRepository _repository;

  ExercisesCubit(this._repository) : super(ExercisesInitial());
  void reset() {
    emit(ExercisesInitial());
  }
  Future<void> fetchExercises({
    int? categoryId,
    int? organId,
    List<int>? smallestCategoryId,
    bool forceRefresh = false,
  }) async {
    emit(ExercisesLoading());

    final result = await _repository.getExercises(
      categoryId: categoryId,
      organId: organId,
      smallestCategoryId: smallestCategoryId,
    );

    if (isClosed) return;

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