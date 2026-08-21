import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart'; // تأكدي من مسار الـ ApiResult
import '../../data/models/notification_model.dart';
import '../../data/repository/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  List<NotificationModel> notificationsList = [];
  int currentPage = 1;
  bool hasReachedMax = false;
  bool isFetching = false;

  int unreadCount = 0;

  void getUnreadCount() async {
    final result = await _repository.fetchUnreadCount();

    if (result is Success<int>) {
      unreadCount = result.data;
      emit(UnreadCountSuccess(unreadCount));
    }
  }
  void incrementUnreadCount() {
    unreadCount++;
    emit(UnreadCountSuccess(unreadCount));
  }
  void getNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasReachedMax = false;
      notificationsList.clear();
    }

    if (hasReachedMax || isFetching) return;

    isFetching = true;

    if (currentPage == 1) {
      emit(NotificationsLoading());
    } else {
      emit(NotificationsPaginationLoading());
    }

    final result = await _repository.fetchNotifications(currentPage);

    if (result is Success<List<NotificationModel>>) {
      final newNotifications = result.data;

      if (newNotifications.isEmpty || newNotifications.length < 20) {
        hasReachedMax = true;
      }

      final markedAsReadNotifications = newNotifications.map((notif) {
        return NotificationModel(
          id: notif.id,
          eventType: notif.eventType,
          model: notif.model,
          modelId: notif.modelId,
          deepLink: notif.deepLink,
          iconUrl: notif.iconUrl,
          title: notif.title,
          body: notif.body,
          isRead: true,
          readAt: notif.readAt ?? DateTime.now().toIso8601String(),
          createdAt: notif.createdAt,
        );
      }).toList();

      notificationsList.addAll(markedAsReadNotifications);
      currentPage++;

      unreadCount = 0;

      emit(NotificationsSuccess(notificationsList, hasReachedMax));
    } else if (result is Failure<List<NotificationModel>>) {
      if (currentPage == 1) {
        emit(NotificationsError(result.message));
      } else {
        emit(NotificationsSuccess(notificationsList, hasReachedMax));
      }
    }

    isFetching = false;
  }
}