import '../../../../../core/network/api_error_handler.dart';
import '../../../../../core/network/api_result.dart';
import '../models/notification_model.dart';
import '../web_services/notifications_web_service.dart';

class NotificationsRepository {
  final NotificationsWebService _webService;

  NotificationsRepository(this._webService);

  // 1️⃣ دالة جلب عدد الإشعارات الغير مقروءة
  Future<ApiResult<int>> fetchUnreadCount() async {
    try {
      final response = await _webService.getUnreadNotificationsCount();

      // استخراج الرقم من الريسبونس (حسب شكل البوستمان اللي بعتيه)
      final int count = response.data['data']['unread_count'];

      return Success(count);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  // 2️⃣ دالة جلب قائمة الإشعارات
  Future<ApiResult<List<NotificationModel>>> fetchNotifications(int page) async {
    try {
      final response = await _webService.getNotifications(page: page);

      // استخراج اللستة من الريسبونس (لاحظي إنو اللستة موجودة جوا data جوا data)
      final List dynamicList = response.data['data']['data'];

      // تحويل الـ JSON إلى لستة من الموديل اللي عملناه
      final List<NotificationModel> notifications = dynamicList
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      return Success(notifications);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}