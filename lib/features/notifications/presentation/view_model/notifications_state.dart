import '../../data/models/notification_model.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class UnreadCountSuccess extends NotificationsState {
  final int count;
  UnreadCountSuccess(this.count);
}

class NotificationsLoading extends NotificationsState {}
class NotificationsPaginationLoading extends NotificationsState {}

class NotificationsSuccess extends NotificationsState {
  final List<NotificationModel> notifications;
  final bool hasReachedMax;

  NotificationsSuccess(this.notifications, this.hasReachedMax);
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}