import '../../../data/models/exercise_model.dart';

sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchSuccess extends SearchState {
  final List<ExerciseModel> exercises;
  SearchSuccess(this.exercises);
}

final class SearchFailure extends SearchState {
  final String errorMessage;
  SearchFailure(this.errorMessage);
}