import 'package:bloc/bloc.dart';

import '../../../../../core/network/api_result.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repository/workout_repository.dart';

class SavedExercisesCubit extends Cubit<void> {
  final WorkoutRepository _repository;
  SavedExercisesCubit(this._repository) : super(null);

  Future<void> toggleSave(ExerciseModel exercise) async {
    exercise.isSaved = !exercise.isSaved;
    emit(null);

    final result = await _repository.toggleSaveExercise(exercise.id);

    if (result is Failure) {
      exercise.isSaved = !exercise.isSaved;
      emit(null);
    }
  }
}