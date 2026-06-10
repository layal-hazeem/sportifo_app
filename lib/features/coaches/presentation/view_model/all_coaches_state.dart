import '../../data/models/coach_model.dart';

sealed class AllCoachesState {}

final class AllCoachesInitial extends AllCoachesState {}

final class AllCoachesLoading extends AllCoachesState {}

final class AllCoachesLoaded extends AllCoachesState {
  final List<CoachModel> coaches;
  AllCoachesLoaded(this.coaches);
}

final class AllCoachesError extends AllCoachesState {
  final String message;
  AllCoachesError(this.message);
}