import '../../../data/models/exercise_model.dart';

abstract class AlternativesState {}

class AlternativesInitial extends AlternativesState {}

class AlternativesLoading extends AlternativesState {}

class AlternativesSuccess extends AlternativesState {
  final List<ExerciseModel> exercises;
  AlternativesSuccess(this.exercises);
}

class AlternativesError extends AlternativesState {
  final String message;
  AlternativesError(this.message);
}