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

    if (result is Success<List<NotificationModel>>) {
      final newNotifications = result.data;

      // إذا رجع أقل من 20 إشعار (الـ per_page)، معناها هي آخر صفحة
      if (newNotifications.isEmpty || newNotifications.length < 20) {
        hasReachedMax = true;
      }

      notificationsList.addAll(newNotifications);
      currentPage++;

      // 💡 حركة ذكية: السيرفر بيعتبرهن انقرأوا بس نطلب اللستة، فمنصفر العداد محلياً
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