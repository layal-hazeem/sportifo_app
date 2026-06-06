import '../../data/models/coach_details_model.dart';

sealed class CoachDetailsState {}
final class CoachDetailsInitial extends CoachDetailsState {}
final class CoachDetailsLoading extends CoachDetailsState {}
final class CoachDetailsLoaded extends CoachDetailsState {
  final CoachDetailsModel coachDetails;
  CoachDetailsLoaded(this.coachDetails);
}
final class CoachDetailsError extends CoachDetailsState {
  final String message;
  CoachDetailsError(this.message);
}