import '../../../../../core/network/api_error_handler.dart';
import '../../../../../core/network/api_result.dart';
import '../models/notification_model.dart';
import '../web_services/notifications_web_service.dart';

class NotificationsRepository {
  final NotificationsWebService _webService;

  NotificationsRepository(this._webService);

  Future<ApiResult<int>> fetchUnreadCount() async {
    try {
      final response = await _webService.getUnreadNotificationsCount();

      final int count = response.data['data']['unread_count'];

      return Success(count);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<NotificationModel>>> fetchNotifications(int page) async {
    try {
      final response = await _webService.getNotifications(page: page);

      final List dynamicList = response.data['data']['data'];

      final List<NotificationModel> notifications = dynamicList
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      return Success(notifications);
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}