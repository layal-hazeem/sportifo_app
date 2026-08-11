import '../../../data/models/exercise_model.dart';

sealed class SavedExercisesState {}

final class SavedExercisesInitial extends SavedExercisesState {}

final class SavedExercisesLoading extends SavedExercisesState {}

final class SavedExercisesSuccess extends SavedExercisesState {
  final List<ExerciseModel> savedExercises;
  SavedExercisesSuccess(this.savedExercises);
}

final class SavedExercisesError extends SavedExercisesState {
  final String message;
  SavedExercisesError(this.message);
}

final class SavedExercisesToggleLoading extends SavedExercisesState {
  final int exerciseId;
  SavedExercisesToggleLoading(this.exerciseId);
}

final class SavedExercisesToggleSuccess extends SavedExercisesState {
  final int exerciseId;
  final bool isSaved;
  SavedExercisesToggleSuccess(this.exerciseId, this.isSaved);
}
