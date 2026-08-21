import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';

class NotificationsWebService {
  final Dio _dio;

  NotificationsWebService(this._dio);

  Future<Response> getUnreadNotificationsCount({Options? options}) async {
    return await _dio.get(
       ApiConstants.notificationsCount ,
      options: options,
    );
  }

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