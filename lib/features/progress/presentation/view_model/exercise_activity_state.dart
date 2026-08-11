import '../../data/models/exercise_activity_model.dart';

sealed class ExerciseActivityState {}

final class ExerciseActivityInitial extends ExerciseActivityState {}

final class ExerciseActivityLoading extends ExerciseActivityState {}

final class ExerciseActivitySuccess extends ExerciseActivityState {
  final List<DayActivity> days;
  ExerciseActivitySuccess(this.days);
}

final class ExerciseActivityError extends ExerciseActivityState {
  final String message;
  ExerciseActivityError(this.message);
}