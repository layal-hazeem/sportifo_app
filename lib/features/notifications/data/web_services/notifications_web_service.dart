import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';

class NotificationsWebService {
  final Dio _dio;

  NotificationsWebService(this._dio);

  // 1️⃣ إند بوينت جلب عدد الإشعارات الغير مقروءة
  Future<Response> getUnreadNotificationsCount({Options? options}) async {
    return await _dio.get(
       ApiConstants.notificationsCount ,
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
       ApiConstants.notifications,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      options: options,
    );
  }
}