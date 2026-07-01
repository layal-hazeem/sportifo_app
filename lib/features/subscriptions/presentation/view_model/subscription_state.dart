part of 'subscription_cubit.dart';

@immutable
sealed class SubscriptionState {}

final class SubscriptionInitial extends SubscriptionState {}

final class SubscriptionLoading extends SubscriptionState {}
final class SubscriptionSuccess extends SubscriptionState {
  final List<UsersSubscribedModel> usersWithSubscriptions;

  SubscriptionSuccess({required this.usersWithSubscriptions});
}
final class SubscriptionError extends SubscriptionState {
  final String errorMessage;

  SubscriptionError({required this.errorMessage});
}