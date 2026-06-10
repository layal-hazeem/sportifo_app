import '../../data/models/coach_model.dart';

sealed class CoachesState {}
final class CoachesInitial extends CoachesState {}
final class CoachesLoading extends CoachesState {}
final class CoachesLoaded extends CoachesState {
  final List<CoachModel> coaches;
  CoachesLoaded(this.coaches);
}
final class CoachesError extends CoachesState {
  final String message;
  CoachesError(this.message);
}