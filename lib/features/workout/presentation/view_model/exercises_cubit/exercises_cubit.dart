import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../../data/repository/workout_repository.dart';
import 'exercises_state.dart';

class ExercisesCubit extends Cubit<ExercisesState> {
  final WorkoutRepository _repository;
  bool _isFetching = false;

  ExercisesCubit(this._repository) : super(ExercisesInitial());

  Future<void> fetchExercises({
    int? categoryId,
    int? organId,
    List<int>? smallestCategoryId,
    bool forceRefresh = false,
  }) async {
    if (_isFetching) return;
    if (!forceRefresh && state is ExercisesSuccess) return;

    _isFetching = true;
    emit(ExercisesLoading());

    final result = await _repository.getExercises(
      categoryId: categoryId,
      organId: organId,
      smallestCategoryId: smallestCategoryId,
    );

    _isFetching = false;
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(ExercisesSuccess(result.data));
      case Failure():
        emit(ExercisesFailure(result.message));
    }
  }

  void retry({int? categoryId, int? organId, List<int>? smallestCategoryId}) {
    fetchExercises(
      categoryId: categoryId,
      organId: organId,
      smallestCategoryId: smallestCategoryId,
      forceRefresh: true,
    );
  }
}