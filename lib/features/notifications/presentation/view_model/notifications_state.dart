import '../../data/models/notification_model.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

// 🔴 حالات جلب عدد الإشعارات الجديدة (العداد)
class UnreadCountSuccess extends NotificationsState {
  final int count;
  UnreadCountSuccess(this.count);
}

// 🟢 حالات جلب قائمة الإشعارات
class NotificationsLoading extends NotificationsState {} // تحميل أول مرة
class NotificationsPaginationLoading extends NotificationsState {} // تحميل الصفحة التالية

class NotificationsSuccess extends NotificationsState {
  final List<NotificationModel> notifications;
  final bool hasReachedMax; // لمعرفة إذا وصلنا لآخر الإشعارات وماعاد في صفحات

  NotificationsSuccess(this.notifications, this.hasReachedMax);
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}