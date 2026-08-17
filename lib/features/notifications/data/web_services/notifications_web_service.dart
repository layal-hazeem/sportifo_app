import 'package:dio/dio.dart';
// إذا ضفتي الروابط بملف الثوابت اعملي import للـ ApiConstants هون

class NotificationsWebService {
  final Dio _dio;

  NotificationsWebService(this._dio);

  // 1️⃣ إند بوينت جلب عدد الإشعارات الغير مقروءة
  Future<Response> getUnreadNotificationsCount({Options? options}) async {
    return await _dio.get(
      'notifications/count', // فيك تبدليها بـ ApiConstants.notificationsCount إذا ضفتيها
      options: options,
    );
  }

  // 2️⃣ إند بوينت جلب لستة الإشعارات (مع الـ Pagination)
  Future<Response> getNotifications({
    required int page,
    int perPage = 20,
    Options? options,
  }) async {
    return await _dio.get(
      'notifications', // فيك تبدليها بـ ApiConstants.notifications
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      options: options,
    );
  }
}