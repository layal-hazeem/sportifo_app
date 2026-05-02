
import '../../../data/models/exercise_model.dart';

sealed class ExercisesState {}

final class ExercisesInitial extends ExercisesState {}

final class ExercisesLoading extends ExercisesState {}

final class ExercisesSuccess extends ExercisesState {
  final List<ExerciseModel> exercises;
  ExercisesSuccess(this.exercises);
}

final class ExercisesFailure extends ExercisesState {
  final String errorMessage;
  ExercisesFailure(this.errorMessage);
}