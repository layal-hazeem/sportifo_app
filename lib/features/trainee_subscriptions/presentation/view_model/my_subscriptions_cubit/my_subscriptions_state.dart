
import '../../../data/models/my_subscription_record_model.dart';

abstract class MySubscriptionsState {}

class MySubscriptionsInitial extends MySubscriptionsState {}
class MySubscriptionsLoading extends MySubscriptionsState {}
class MySubscriptionsSuccess extends MySubscriptionsState {
  final List<MySubscriptionRecordModel> subscriptions;
  MySubscriptionsSuccess(this.subscriptions);
}
class MySubscriptionsError extends MySubscriptionsState {
  final String message;
  MySubscriptionsError(this.message);
}