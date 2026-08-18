import 'package:sportifo_app/features/coaches/data/models/coach_model.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';

sealed class CoachHomeState {}

class CoachHomeLoading extends CoachHomeState {}

class CoachHomeLoaded extends CoachHomeState {
  final CoachModel coach;
  final int notificationsCount;
  final List<UsersSubscribedModel> clients;

  CoachHomeLoaded({
    required this.coach,
    required this.notificationsCount,
    required this.clients,
  });
}

class CoachHomeError extends CoachHomeState {
  final String message;

  CoachHomeError(this.message);
}