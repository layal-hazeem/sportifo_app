import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart'; // تأكدي من مسار الـ ApiResult
import '../../data/models/notification_model.dart';
import '../../data/repository/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  // متغيرات لحفظ حالة اللستة والصفحات (Pagination)
  List<NotificationModel> notificationsList = [];
  int currentPage = 1;
  bool hasReachedMax = false;
  bool isFetching = false;

  // متغير لحفظ عدد الإشعارات الغير مقروءة
  int unreadCount = 0;

  // 🔥 1. دالة جلب العداد (بنستدعيها أول ما يفتح التطبيق أو من الـ Bottom Nav Bar)
  void getUnreadCount() async {
    final result = await _repository.fetchUnreadCount();

    if (result is Success<int>) {
      unreadCount = result.data;
      emit(UnreadCountSuccess(unreadCount));
    }
    // في حال الفشل مابنعمل شي مشان ما نزعج اليوزر بإيرور للعداد
  }
// دالة لزيادة العداد فوراً عند وصول إشعار جديد والتطبيق مفتوح
  void incrementUnreadCount() {
    unreadCount++;
    emit(UnreadCountSuccess(unreadCount));
  }
  // 🔥 2. دالة جلب قائمة الإشعارات (مع دعم الـ Pagination والـ Refresh)
  void getNotifications({bool isRefresh = false}) async {
    // إذا عم نعمل سحب للأسفل (Pull to refresh) بنصفر كل شي
    if (isRefresh) {
      currentPage = 1;
      hasReachedMax = false;
      notificationsList.clear();
    }

    // إذا عم يحمل حالياً أو وصلنا للآخر، لا تعمل ريكويست جديد
    if (hasReachedMax || isFetching) return;

    isFetching = true;

    // إظهار حالة التحميل (كاملة لأول مرة، أو مصغرة للصفحات التالية)
    if (currentPage == 1) {
      emit(NotificationsLoading());
    } else {
      emit(NotificationsPaginationLoading());
    }

    final result = await _repository.fetchNotifications(currentPage);

    // في دالة getNotifications، استبدلي هذا الجزء:
    if (result is Success<List<NotificationModel>>) {
      final newNotifications = result.data;

      // إذا رجع أقل من 20 إشعار (الـ per_page)، معناها هي آخر صفحة
      if (newNotifications.isEmpty || newNotifications.length < 20) {
        hasReachedMax = true;
      }

      // 🔥 الحل السحري: نجبر كل الإشعارات الجديدة أن تصبح "مقروءة" في الفرونت إند
      // لأننا فتحنا الشاشة للتو
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
          isRead: true, // 👈 نجعلها true يدوياً ليختفي اللون البرتقالي
          readAt: notif.readAt ?? DateTime.now().toIso8601String(),
          createdAt: notif.createdAt,
        );
      }).toList();

      notificationsList.addAll(markedAsReadNotifications);
      currentPage++;

      // نصفر العداد لأننا رأينا الإشعارات
      unreadCount = 0;

      emit(NotificationsSuccess(notificationsList, hasReachedMax));
    } else if (result is Failure<List<NotificationModel>>) {
      // إرجاع الإيرور فقط إذا كانت أول صفحة (عشان ما تخرب اللستة إذا انقطع النت بالنص)
      if (currentPage == 1) {
        emit(NotificationsError(result.message));
      } else {
        emit(NotificationsSuccess(notificationsList, hasReachedMax));
      }
    }

    isFetching = false;
  }
}