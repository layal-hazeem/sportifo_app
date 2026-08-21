import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';

class SubscriptionWebService {
  final Dio _dio;

  SubscriptionWebService(this._dio);

  Future<Map<String, dynamic>> getSubscriptions({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _dio.get(
        AppRoutes.usersSubscribed,
        options: forceRefresh
            ? CacheOptions(policy: CachePolicy.refresh, store: null).toOptions()
            : null,
      );

      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Response data is empty');
    } catch (e) {
      rethrow;
    }
  }
}
